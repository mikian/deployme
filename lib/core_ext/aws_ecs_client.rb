require 'aws-sdk-ecs'

class Aws::ECS::Client # rubocop:disable Style/ClassAndModuleChildren
  def upsert_service(options)
    send(:update_service, options)
  rescue Aws::ECS::Errors::ServiceNotFoundException, Aws::ECS::Errors::ServiceNotActiveException
    options[:service_name] = options.delete(:service)
    send(:create_service, options)
  end
end
