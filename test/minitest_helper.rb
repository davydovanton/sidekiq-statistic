# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/mock'

require 'rack/test'

require 'sidekiq'
require 'sidekiq-statistic'

Sidekiq.logger.level = Logger::ERROR

class HistoryWorker
  include Sidekiq::Worker
end

class HistoryWorkerWithQueue
  include Sidekiq::Worker
  sidekiq_options queue: :new
end

class OtherHistoryWorker
  include Sidekiq::Worker
end

class ActiveJobWrapper
  include Sidekiq::Worker
end

module Nested
  class HistoryWorker
    include Sidekiq::Worker
  end
end

def travel_to(time)
  Time.stub :now, time do
    yield
  end
end

def middlewared(worker_class = HistoryWorker, msg = {})
  middleware = Sidekiq::Statistic::Middleware.new
  middleware.call worker_class.new, msg, 'default' do
    yield
  end
end
