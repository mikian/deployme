require 'ostruct'

module Deployme
  class Options
    def initialize(hash)
      @data = OpenStruct.new(hash)

      # Set defaults
      @data.name ||= File.basename(File.expand_path('.'))
      @data.directory ||= File.expand_path('.deploy')
    end

    def git_commit
      @data.git_commit ||= ENV.fetch('GIT_COMMIT') { `git rev-parse HEAD`.strip }
    end

    def git_branch
      @data.git_branch ||= ENV.fetch('GIT_BRANCH') { `git rev-parse HEAD | git branch -a --contains | sed -n 2p | cut -d'/' -f 3-`.strip }
    end

    def change_id
      @data.change_id ||= ENV.fetch('CHANGE_ID', nil)
    end

    def deploy_name
      "#{@data.name}-pr-#{change_id}"
    end

    def deploy_host
      @data.deploy_host ||= "#{deploy_name}.#{@data.deploy_domain}"
    end

    def deploy_url
      @data.deploy_url ||= "https://#{deploy_host}"
    end

    def method_missing(meth, *args, &blk)
      @data.send(meth, *args, &blk)
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.respond_to?(method_name, include_private) || super
    end
  end
end
