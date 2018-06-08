require 'jira-ruby'

module Deployme
  module Notifications
    class Jira < Notification
      def self.options(parser)
        parser.on('--jira-issues=TICKET,TICKET', Array, 'JIRA Tickets to Update') { |options, value| options.jira_issues = value }
        parser.on('--jira-url=URL', String, 'JIRA Instance URL') { |options, value| options.jira_url = value }
        parser.on('--jira-username=USERNAME', String, 'JIRA Instance Username') { |options, value| options.jira_username = value }
        parser.on('--jira-token=PASSWORD', String, 'JIRA Instance Password') { |options, value| options.jira_token = value }
      end

      def notify_start
      end

      def notify_error(error = nil); end

      def notify_finish
        return unless settings.issues

        logger.info 'Adding Website link to JIRA'
        settings.issues.each do |issue_key|
          logger.info "Finding Issue: #{issue_key}"
          next if options.dry_run

          issue = client.Issue.find(issue_key)
          next if issue.remotelink.all.any? { |link| link.attrs['object']['url'] == deployment.options.deploy_url }

          logger.info "Adding link to #{deployment.options.deploy_url}"
          link = issue.remotelink.build
          link.save(
            object: {
              url: deployment.options.deploy_url,
              title: deployment.options.deploy_url
            }
          )
        end
      end

      private

      def client
        @client ||= JIRA::Client.new(
          username: settings.username,
          password: settings.token,
          site: settings.url,
          context_path: '',
          auth_type: :basic,
          http_debug: true
        )
      end
    end
  end
end
