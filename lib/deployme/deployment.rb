require 'deployme/config'
require 'deployme/notification'
require 'deployme/provider'
require 'deployme/util'
require 'logger'

module Deployme
  class Deployment
    def self.options(parser)
      parser.separator ''
      parser.separator 'Deployment Options:'

      parser.on('--url=URL', String, 'URL for deployment environment') { |options, value| options.deploy_url = value }
      parser.on('--domain=domain', String, 'URL for deployment environment') { |options, value| options.deploy_domain = value }
      parser.on('-nNAME', '--name=NAME', String, 'Deployment name') { |options, value| options.name = value }
      parser.on('-eENVIRONMENT', '--environment=ENVIRONMENT', String, 'Environment to deploy to') { |options, value| options.environment = value }
      parser.on('-dDIRECTORY', '--directory=DIRECTORY', String, 'Directory where to find deployment instructions') { |options, value| options.directory = File.expand_path(value) }

      parser.on('--commit=COMMIT', String, 'Git Commit to deploy') { |options, value| options.git_commit = value }
      parser.on('--branch=BRANCH', String, 'Git Branch to deploy') { |options, value| options.git_branch = value }
      parser.on('--change-id=CHANGE_ID', String, 'Change ID (Pull Request) to deploy') { |options, value| options.change_id = value }
    end

    attr_reader :config, :options

    def initialize(options:)
      @options = options
      @config ||= Config.new(options: options).load
    end

    def run
      providers.each(&:deploy)
    end

    def notify(stage, *args)
      notifications.each do |notification|
        notification.public_send("notify_#{stage}", *args)
      end
    end

    # Attributes
    def logger
      @logger ||= Logger.new(STDOUT).tap do |logger|
        logger.formatter = proc do |severity, _datetime, _progname, msg|
          status = case severity
                   when 'INFO'    then "\e[34m==>\e[0m"
                   when 'WARNING' then "\e[33m==>\e[0m"
                   when 'ERROR'   then "\e[31m==>\e[0m"
                   end

          format("%<status>s %<msg>s\n", status: status, msg: msg)
        end
      end
    end

    def environment
      options.environment
    end

    private

    def providers
      @providers ||= config[:providers].map do |type, options|
        Providers.const_get(Util.camelize(type)).new(deployment: self, config: options || {})
      end
    end

    def notifications
      @notifications ||= config[:notifications].map do |type, options|
        Notifications.const_get(Util.camelize(type)).new(deployment: self, config: options || {})
      end
    end
  end
end
