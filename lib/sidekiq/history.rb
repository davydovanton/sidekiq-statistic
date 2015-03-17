begin
  require 'sidekiq/web'
rescue LoadError
  # client-only usage
end

require 'sidekiq/api'
require 'sidekiq/history/log_parser'
require 'sidekiq/history/middleware'
require 'sidekiq/history/web_extension'
require 'sidekiq/history/worker_statistic'
require 'sidekiq/history/version'

module Sidekiq
  module History
    # Your code goes here...
  end
end

# Add configuration patterns. For this reed this link:
#   http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::History::Middleware
  end
end

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::History::WebExtension
  Sidekiq::Web.tabs['History'] = 'history'
end
