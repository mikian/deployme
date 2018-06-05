module Deployme
  module Notifications
    class Envfile < Notification
      def self.options(parser)
        parser.on('--envfile-path=NAME', String, 'Environment File to Write out') { |options, value| options.envfile_path = value }
      end

      def notify_start; end

      def notify_error(error = nil); end

      def notify_finish
        File.open(settings.path, 'w') do |f|
          f.puts "DEPLOYMENT_URL=#{deployment.options.deploy_url}"
        end
      end
    end
  end
end
