require 'optparse'
require 'ostruct'

module Deployme
  class OptionParser < ::OptionParser
    def self.run(args, &block)
      new(&block).run(args)
    end

    def initialize(&block)
      @options = OpenStruct.new
      super
    end

    def on(*args)
      super(*args) do |value|
        yield(@options, value)
      end
    end

    def on_tail(*args)
      super(*args) do
        yield(@options)
      end
    end

    def run(args)
      begin
        parse!(args)
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts $ERROR_INFO.to_s
        puts
        puts self
        exit 1
      end

      @options
    end
  end
end
