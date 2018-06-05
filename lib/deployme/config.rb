require 'erb'
require 'yaml'

module Deployme
  class Config
    def initialize(options:)
      @options = options
    end

    def load
      file = File.join(options.directory, "#{options.environment}.yml")

      raise "Cannot find environment #{file}" unless File.exist?(file)

      YAML.load(ERB.new(File.read(file)).result(Context.with(options)), symbolize_names: true)
    end

    private

    attr_reader :options

    class Context
      def self.with(obj)
        new(obj).context
      end

      def initialize(options)
        @options = options
      end

      def method_missing(meth, *args, &blk)
        @options.send(meth, *args, &blk) || super
      end

      def respond_to_missing?(method_name, include_private = false)
        @options.respond_to?(method_name, include_private) || super
      end

      def context
        binding
      end
    end
  end
end
