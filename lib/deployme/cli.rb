require 'deployme/deployment'
require 'deployme/option_parser'
require 'deployme/options'
require 'deployme/provider'
require 'deployme/version'

module Deployme
  class CLI
    def self.run(args)
      runtime = OptionParser.run(args) do |parser|
        (Provider.all + Notification.all).each do |mod|
          parser.separator ''
          parser.separator "#{mod.to_s.split('::').last.upcase} Options:"
          mod.options(parser)
        end

        Deployment.options(parser)

        parser.separator ''
        parser.separator 'Common options:'

        parser.on_tail('-h', '--help', 'Show this message') do
          puts parser
          exit
        end

        parser.on('--dry-run', 'Do not actually do anything') { |options| options.dry_run = true }
        parser.on('--debug', 'Increase verbosity') { |options| options.debug = true }
        parser.on_tail('--version', 'Show version') do
          puts ::Deployme::VERSION
          exit
        end
      end

      Deployment.new(options: Options.new(runtime)).run
    end
  end
end
