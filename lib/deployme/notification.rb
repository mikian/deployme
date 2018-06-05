require 'forwardable'
require 'deployme/settings'

module Deployme
  class Notification
    extend Forwardable

    def self.defaults
      {}
    end

    def self.all
      Notifications.constants.map { |c| Notifications.const_get(c) }
    end

    def initialize(deployment:, config:)
      @deployment = deployment
      @settings = Settings.new(self.class, config, deployment.options)
    end

    private

    attr_reader :deployment, :settings
    delegate logger: :deployment
  end
end

require 'deployme/notifications/envfile'
require 'deployme/notifications/github'
require 'deployme/notifications/jira'
