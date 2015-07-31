# encoding: utf-8

require 'minitest_helper'
require 'sidekiq/web'
require 'json'

module Sidekiq
  describe 'WebApiExtension' do
    include Rack::Test::Methods

    def app
      Sidekiq::Web
    end

    before { Sidekiq.redis(&:flushdb) }

    describe 'GET /api/statistic.json' do
      describe 'without jobs' do
        before do
          get '/api/statistic.json'
        end

        it 'returns empty workers statistic' do
          response = JSON.parse(last_response.body)
          response['workers'].must_equal []
        end
      end

      describe 'for perfomed jobs' do
        before do
          middlewared {}
          get '/api/statistic.json'
        end

        it 'returns workers statistic' do
          response = JSON.parse(last_response.body)
          response['workers'].wont_equal []
          response['workers'].first.keys.must_equal %w[name last_job_status number_of_calls runtime]
        end
      end

      describe 'for any range' do
        describe 'for date range with empty statistic' do
          before do
            middlewared {}
            get '/api/statistic.json?dateFrom=2015-07-28&dateTo=2015-07-29'
          end

          it 'returns empty statistic' do
            response = JSON.parse(last_response.body)
            response['workers'].must_equal []
          end
        end

        describe 'for any date range with existed statistic' do
          before do
            middlewared {}
            get "/api/statistic.json?dateFrom=2015-07-28&dateTo=#{Date.today}"
          end

          it 'returns workers statistic' do
            response = JSON.parse(last_response.body)
            response['workers'].wont_equal []
            response['workers'].count.must_equal 1
          end
        end
      end
    end

    describe 'GET /api/statistic/:worker.json' do
      before do
        get '/api/statistic/:worker.json'
        middlewared {}
      end

      it '' do
      end
    end
  end
end
