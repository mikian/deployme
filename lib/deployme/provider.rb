require 'forwardable'
require 'deployme/settings'

module Deployme
  class Provider
    extend Forwardable

    def self.defaults
      {}
    end

    def self.all
      Providers.constants.map { |c| Providers.const_get(c) }
    end

    def initialize(deployment:, config:)
      @deployment = deployment
      @settings = Settings.new(self.class, config, deployment.options)
    end

    def deploy
      deployment.notify(:start)

      execute

      deployment.notify(:finish)
    rescue StandardError => e
      deployment.notify(:error, e)
      throw e
    end

    def execute
      raise NotImplementedError
    end

    private

    attr_reader :deployment, :settings
    delegate logger: :deployment
  end
end

require 'deployme/providers/ecs'
