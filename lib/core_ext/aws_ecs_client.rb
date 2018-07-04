require 'aws-sdk-ecs'

class Aws::ECS::Client # rubocop:disable Style/ClassAndModuleChildren
  def upsert_service(options)
    active_services = describe_services(
      cluster: options[:cluster], services: [options[:service]]
    ).services.any? { |svc| svc.status == 'ACTIVE' }
    if active_services

      send(:update_service, options.tap { |o| o.delete(:load_balancers) })
    else
      options[:service_name] = options.delete(:service)
      send(:create_service, options)
    end
  end
end
