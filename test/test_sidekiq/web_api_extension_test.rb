# frozen_string_literal: true

# encoding: utf-8

require 'minitest_helper'

module Sidekiq
  describe 'WebApiExtension' do
    include Rack::Test::Methods

    def app
      Sidekiq::Web
    end

    before { Sidekiq.redis(&:flushdb) }

    describe 'GET /api/statistic.json' do
      describe 'without jobs' do
        it 'returns empty workers statistic' do
          get '/api/statistic.json'

          response = Sidekiq.load_json(last_response.body)
          response['workers'].must_equal []
        end
      end

      describe 'for perfomed jobs' do
        it 'returns workers statistic' do
          middlewared {}
          get '/api/statistic.json'

          response = Sidekiq.load_json(last_response.body)
          response['workers'].wont_equal []
          response['workers'].first.keys.must_equal %w[name last_job_status number_of_calls queue runtime]
        end
      end

      describe 'for any range' do
        before do
          middlewared {}
        end

        describe 'for date range with empty statistic' do
          it 'returns empty statistic' do
            get '/api/statistic.json?dateFrom=2015-07-28&dateTo=2015-07-29'

            response = Sidekiq.load_json(last_response.body)
            response['workers'].must_equal []
          end
        end

        describe 'for any date range with existed statistic' do
          it 'returns workers statistic' do
            get "/api/statistic.json?dateFrom=2015-07-28&dateTo=#{Date.today}"

            response = Sidekiq.load_json(last_response.body)
            response['workers'].wont_equal []
            response['workers'].count.must_equal 1
          end
        end
      end
    end

    describe 'GET /api/statistic/:worker.json' do
      describe 'without jobs' do
        it 'returns empty workers statistic' do
          get '/api/statistic/HistoryWorker.json'

          response = Sidekiq.load_json(last_response.body)
          response['days'].must_equal []
        end
      end

      describe 'for perfomed jobs' do
        it 'returns workers statistic' do
          middlewared {}
          get '/api/statistic/HistoryWorker.json'

          response = Sidekiq.load_json(last_response.body)
          response['days'].wont_equal []
          response['days'].first.keys.must_equal %w[date failure success total last_job_status runtime]
        end
      end

      describe 'for any range' do
        before do
          middlewared {}
        end

        describe 'for date range with empty statistic' do
          it 'returns empty statistic' do
            get '/api/statistic/HistoryWorker.json?dateFrom=2015-07-28&dateTo=2015-07-29'

            response = Sidekiq.load_json(last_response.body)
            response['days'].must_equal []
          end
        end

        describe 'for any date range with existed statistic' do
          it 'returns workers statistic' do
            get "/api/statistic/HistoryWorker.json?dateFrom=2015-07-28&dateTo=#{Date.today}"

            response = Sidekiq.load_json(last_response.body)
            response['days'].wont_equal []
            response['days'].count.must_equal 1
          end
        end
      end
    end
  end
end
