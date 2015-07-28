begin
  require 'sidekiq/web'
rescue LoadError
  # client-only usage
end

require 'sidekiq/api'
require 'sidekiq/history/configuration'
require 'sidekiq/history/log_parser'
require 'sidekiq/history/middleware'
require 'sidekiq/history/statistic'
require 'sidekiq/history/statistic/charts'
require 'sidekiq/history/statistic/runtime'
require 'sidekiq/history/statistic/workers'
require 'sidekiq/history/version'
require 'sidekiq/history/web_extension'

module Sidekiq
  module History
    REDIS_HASH = 'sidekiq:history'.freeze

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
    chain.add Sidekiq::History::Middleware
  end
end

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::History::WebExtension
  Sidekiq::Web.tabs['History'] = 'history'
end
