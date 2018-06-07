require 'net/http'
require 'json'

module Deployme
  module Notifications
    class Github < Notification
      def self.options(parser)
        parser.on('--github-token=NAME', String, 'GitHub Token to send Deployments') { |options, value| options.github_token = value }
      end

      def notify_start
        logger.info 'Create GitHub Deployment...'
        return if options.dry_run
        @github_deployment = request(
          :post,
          'https://api.github.com/repos/appearhere/web/deployments',
          ref: deployment.options.git_commit,
          environment: deployment.environment,
          auto_merge: false,
          transient_environment: deployment.environment != 'production',
          production_environment: deployment.environment == 'production',
          required_contexts: []
        )
        return if @github_deployment['id']

        logger.error 'Failed to create GitHub Deployment'
        logger.error @github_deployment['message']
        raise
      end

      def notify_error(error = nil)
        return unless @github_deployment

        logger.error 'Reporting Error to GitHub'
        response = request(
          :post,
          "https://api.github.com/repos/appearhere/web/deployments/#{@github_deployment['id']}/statuses",
          state: 'error',
          description: error.to_s[0...140]
        )
        return if response['id']
        logger.error response['message']
      end

      def notify_finish
        return unless @github_deployment

        logger.info 'Successful GitHub Deployment...'
        request(
          :post,
          "https://api.github.com/repos/appearhere/web/deployments/#{@github_deployment['id']}/statuses",
          state: 'success',
          environment_url: deployment.options.deploy_url,
          description: 'Review app created successfully.'
        )
      end

      private

      def header
        {
          'Accept' => 'application/vnd.github.ant-man-preview+json',
          'Content-Type' => 'text/json',
          'Authorization' => "token #{settings.token}"
        }
      end

      def request(method, url, data = nil)
        uri = URI.parse(url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = case method
                  when :get
                    Net::HTTP::Get.new(uri.request_uri, header)
                  when :post
                    Net::HTTP::Post.new(uri.request_uri, header)
                  end
        request.body = data.to_json if data

        # Send the request
        response = http.request(request)
        JSON.parse(response.body)
      end
    end
  end
end
