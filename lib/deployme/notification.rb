require 'forwardable'

module Deployme
  class Notification
    extend Forwardable

    def self.all
      Notifications.constants.map{|c| Notifications.const_get(c) }
    end

    def initialize(deployment:, config:)
      @deployment = deployment
      @config = config
    end

    private

    attr_reader :deployment, :config
    delegate logger: :deployment
  end
end

require 'deployme/notifications/github'
