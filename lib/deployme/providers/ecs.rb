require 'core_ext/aws_ecs_client'

module Deployme
  module Providers
    class Ecs < Provider
      def self.options(parser)
        parser.on('--ecs-image=IMAGE_TAG', String, 'Image tag to use for deployment') { |options, value| options.ecs_image = value }
        parser.on('--ecs-cluster=NAME', String, 'ECS Cluster name to deploy to')   { |options, value| options.ecs_cluster = value }
      end

      def execute
        return if options.dry_run
        register_tasks
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
        config[:services].each do |service|
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
