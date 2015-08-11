begin
  require 'sidekiq/web'
rescue LoadError
  # client-only usage
end

require 'sidekiq/api'
require 'sidekiq/statistic/configuration'
require 'sidekiq/statistic/log_parser'
require 'sidekiq/statistic/middleware'
require 'sidekiq/statistic/base'
require 'sidekiq/statistic/statistic/charts'
require 'sidekiq/statistic/statistic/realtime'
require 'sidekiq/statistic/statistic/runtime'
require 'sidekiq/statistic/statistic/workers'
require 'sidekiq/statistic/version'
require 'sidekiq/statistic/web_extension'
require 'sidekiq/statistic/web_api_extension'
require 'sidekiq/statistic/web_extension_helper'

module Sidekiq
  module Statistic
    REDIS_HASH = 'sidekiq:statistic'.freeze

    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Statistic::Middleware
  end
end

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::Statistic::WebApiExtension
  Sidekiq::Web.register Sidekiq::Statistic::WebExtension
  Sidekiq::Web.tabs['Statistic'] = 'statistic'
end
