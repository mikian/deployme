require 'core_ext/aws_ecs_client'

module Deployme
  module Providers
    class Ecs < Provider
      def self.options(parser)
        parser.on('--ecs-image=IMAGE_TAG', String, 'Image tag to use for deployment') { |options, value| options.ecs_image = value }
        parser.on('--ecs-cluster=NAME', String, 'ECS Cluster name to deploy to') { |options, value| options.ecs_cluster = value }
      end

      def execute
        return if options.dry_run
        register_tasks
        run_tasks
        register_services
      end

      private

      def register_tasks
        config[:task_definitions].each do |family, task_definition|
          logger.info "Registering task: #{family}"
          definition = Util.deep_dup(task_definition)
          definition[:family] = family
          definition[:container_definitions].each { |container| container[:image] ||= options.ecs_image }
          response = client.register_task_definition(definition)
          definition[:arn] = response.task_definition.task_definition_arn
          logger.info "New task definition: #{definition[:arn]}"
          task_definitions[family] = definition
        end
      end

      def register_services
        services = config[:services].map do |service|
          logger.info "Registering Service #{service[:name]}"
          task_definition = task_definitions[service[:task_family].to_sym]

          response = client.upsert_service(
            cluster: options.ecs_cluster,
            service: service[:name],
            desired_count: service[:desired_count],
            task_definition: task_definition[:arn],
            deployment_configuration: service[:deployment_configuration]
          )

          logger.info "Success: #{response.service.status}"
          response.service.service_arn
        end

        begin
          client.wait_until(:services_stable, cluster: options.ecs_cluster, services: services) do |w|
            w.before_wait do
              logger.info 'Waiting for services to stable...'
            end
          end
        rescue Aws::Waiters::Errors::WaiterFailed => error
          logger.error "failed waiting for service: #{error.message}"
          exit(1)
        end
      end

      def report_run_task_failures(failures)
        return if failures.empty?
        failures.each do |failure|
          STDERR.puts "Error: run task failure '#{failure.reason}'"
        end
        exit 1
      end

      # handle one off tasks
      def run_tasks
        config.fetch(:one_off_commands, []).each do |one_off_command|
          task_definition = task_definitions[one_off_command[:task_family].to_sym]
          logger.info "Running '#{one_off_command[:command]}'"
          response = client.run_task(
            cluster: options.ecs_cluster,
            task_definition: task_definition[:arn],
            count: 1,
            started_by: "ecs-deploy: one_off_commands",
            overrides: {
              container_overrides: [
                {
                  name: task_definition[:container_definitions].first[:name],
                  command: Array(one_off_command[:command])
                }
              ]
            }
          )
          # handle potential failures
          report_run_task_failures(response.failures)

          task_arn = response.tasks.first.task_arn
          print "Waiting for '#{one_off_command[:command]}' to finish"
          waiting = 0
          last_now = Time.now
          task = nil
          while waiting <= 1800 do
            task = client.describe_tasks(tasks: [task_arn], cluster: options.ecs_cluster).tasks.first
            break if task.last_status == "STOPPED"
            print "."
            now = Time.now
            waiting += (now - last_now).to_i
            last_now = now
            sleep 5
          end
          if waiting > 1800
            STDERR.puts "Error: wait time exceeded"
            exit 1
          end
          if task.containers.first.exit_code != 0
            STDERR.puts "Error: '#{one_off_command[:command]}' finished with a non-zero exit code! Aborting."
            exit 1
          end
          puts " done!"
        end
      end

      def task_definitions
        @task_definitions ||= {}
      end

      def client
        @client ||= Aws::ECS::Client.new
      end
    end
  end
end
