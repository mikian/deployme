require 'forwardable'

module Deployme
  class Provider
    extend Forwardable

    def self.all
      Providers .constants.map{|c| Providers  .const_get(c) }
    end

    def initialize(deployment:, config:)
      @deployment = deployment
      @config = config
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

    attr_reader :deployment, :config
    delegate logger: :deployment
  end
end

require 'deployme/providers/ecs'
