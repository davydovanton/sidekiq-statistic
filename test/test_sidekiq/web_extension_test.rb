# frozen_string_literal: true

# encoding: utf-8

require 'minitest_helper'
require 'json'

module Sidekiq
  describe 'WebExtension' do
    include Rack::Test::Methods

    def app
      Sidekiq::Web
    end

    describe 'GET /' do
      it 'can show text with any locales' do
        rackenv = { 'HTTP_ACCEPT_LANGUAGE' => 'ru,en' }

        get '/', {}, rackenv

        assert_match(/Статистика/, last_response.body)
        rackenv = { 'HTTP_ACCEPT_LANGUAGE' => 'en-us' }

        get '/', {}, rackenv

        assert_match(/Statistic/, last_response.body)
      end
    end

    describe 'GET /sidekiq' do
      before do
        get '/'
      end

      it 'can display home with statistic tab' do
        _(last_response.status).must_equal 200
        _(last_response.body).must_match(/Sidekiq/)
        _(last_response.body).must_match(/Statistic/)
      end
    end

    describe 'GET /sidekiq/statistic' do
      before do
        get '/statistic'
      end

      it 'can display statistic page without any failures' do
        _(last_response.status).must_equal 200
        _(last_response.body).must_match(/statistic/)
      end

      describe 'when there are statistic' do
        it 'should be successful' do
          _(last_response.status).must_equal 200
        end
      end

      it 'can display worker table' do
        _(last_response.body).must_match(/Worker/)
        _(last_response.body).must_match(/Date/)
        _(last_response.body).must_match(/Success/)
        _(last_response.body).must_match(/Failure/)
        _(last_response.body).must_match(/Total/)
        _(last_response.body).must_match(/Time\(sec\)/)
        _(last_response.body).must_match(/Average\(sec\)/)
      end
    end

    describe 'GET /sidekiq/statistic/charts.json' do
      before do
        get '/statistic/charts.json'
      end

      it 'can display statistic page without any failures' do
        _(last_response.status).must_equal 200
        response = JSON.parse(last_response.body)

        assert_includes response, 'date'
        assert_includes response, 'failed_data'
        assert_includes response, 'passed_data'
        assert_includes response['date'], 'labels'
        assert_includes response['date'], 'format'
      end

      describe 'when there are statistic' do
        it 'should be successful' do
          _(last_response.status).must_equal 200
        end
      end
    end

    describe 'GET /sidekiq/common.css' do
      before do
        get '/common.css'
      end

      it 'displays common styles successfully' do
        _(last_response.status).must_equal 200
        _(last_response.content_type).must_match(/text\/css/)
        _(last_response.body).must_match(/Common Styles/)
      end
    end

    describe 'GET /sidekiq/sidekiq-statistic-light.css' do
      before do
        get '/sidekiq-statistic-light.css'
      end

      it 'displays common styles successfully' do
        _(last_response.status).must_equal 200
        _(last_response.content_type).must_match(/text\/css/)
        _(last_response.body).must_match(/Light Styles/)
      end
    end

    describe 'GET /sidekiq/sidekiq-statistic-dark.css' do
      before do
        get '/sidekiq-statistic-dark.css'
      end

      it 'displays common styles successfully' do
        _(last_response.status).must_equal 200
        _(last_response.content_type).must_match(/text\/css/)
        _(last_response.body).must_match(/Dark Styles/)
      end
    end
  end
end
