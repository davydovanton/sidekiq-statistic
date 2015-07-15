$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'

require 'rack/test'

require 'sidekiq'
require 'sidekiq-history'
require 'sidekiq/history'

Sidekiq.logger.level = Logger::ERROR

class HistoryWorker
  include Sidekiq::Worker
end

class OtherHistoryWorker
  include Sidekiq::Worker
end

def middlewared(worker_class = HistoryWorker)
  middleware = Sidekiq::History::Middleware.new
  middleware.call worker_class.new, {}, 'default' do
    yield
  end
end
