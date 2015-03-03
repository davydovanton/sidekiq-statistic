begin
  require 'sidekiq/web'
rescue LoadError
  # client-only usage
end

require 'sidekiq/api'
require 'sidekiq/history/version'
require 'sidekiq/history/web_extension'

module Sidekiq
  module History
    # Your code goes here...
  end
end

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::History::WebExtension
  Sidekiq::Web.tabs['History'] = 'history'
end
