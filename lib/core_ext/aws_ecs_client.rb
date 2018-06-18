require 'aws-sdk-ecs'

class Aws::ECS::Client # rubocop:disable Style/ClassAndModuleChildren
  def upsert_service(options)
    if describe_services(cluster: options[:cluster], services: [options[:service]]).services.count.zero?
      options[:service_name] = options.delete(:service)
      send(:create_service, options)
    else
      send(:update_service, options)
    end
  end
end
