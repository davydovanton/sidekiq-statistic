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

    it 'can show text with any locales' do
      rackenv = {'HTTP_ACCEPT_LANGUAGE' => 'ru,en'}
      get '/', {}, rackenv
      assert_match(/Статистика/, last_response.body)
      rackenv = {'HTTP_ACCEPT_LANGUAGE' => 'en-us'}
      get '/', {}, rackenv
      assert_match(/Statistic/, last_response.body)
    end

    describe 'GET /sidekiq' do
      before do
        get '/'
      end

      it 'can display home with statistic tab' do
        last_response.status.must_equal 200
        last_response.body.must_match /Sidekiq/
        last_response.body.must_match /Statistic/
      end
    end

    describe 'GET /sidekiq/statistic' do
      before do
        get '/statistic'
      end

      it 'can display statistic page without any failures' do
        last_response.status.must_equal 200
        last_response.body.must_match /statistic/
      end

      describe 'when there are statistic' do
        it 'should be successful' do
          last_response.status.must_equal 200
        end
      end

      it 'can display worker table' do
        last_response.body.must_match /Worker/
        last_response.body.must_match /Date/
        last_response.body.must_match /Success/
        last_response.body.must_match /Failure/
        last_response.body.must_match /Total/
        last_response.body.must_match /Time\(sec\)/
        last_response.body.must_match /Average\(sec\)/
      end
    end

    describe 'GET /sidekiq/statistic/charts.json' do
      before do
        get '/statistic/charts.json'
      end

      it 'can display statistic page without any failures' do
        last_response.status.must_equal 200
        response = JSON.parse(last_response.body)

        response['tooltip_template'].must_equal '<%= datasetLabel %> - <%= value %>'
        response['labels'].wont_be_empty
      end

      describe 'when there are statistic' do
        it 'should be successful' do
          last_response.status.must_equal 200
        end
      end
    end
  end
end
