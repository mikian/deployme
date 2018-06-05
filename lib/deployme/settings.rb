require 'ostruct'

module Deployme
  class Settings
    def initialize(klass, config, options)
      @prefix = klass.to_s.split('::').last.downcase
      @config = OpenStruct.new(klass.defaults.merge(config))
      @options = options
    end

    def method_missing(name, *args, &blk)
      fetch_param(name)
    end

    def respond_to_missing?(method_name, include_private = false)
      detect_param(method_name) || super
    end

    private

    def fetch_param(name)
      @config[name] ||= ENV["#{@prefix}_#{name}".upcase] || @options.send("#{@prefix}_#{name}")
    end

    def detect_param(name)
      @config.respond_to?(name) || ENV.key?("#{@prefix}_#{name}".upcase) || @options.respond_to?("#{@prefix}_#{name}")
    end
  end
end
