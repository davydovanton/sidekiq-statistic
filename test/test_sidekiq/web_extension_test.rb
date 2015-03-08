require 'minitest_helper'
require 'sidekiq/web'
require 'json'

module Sidekiq
  describe 'WebExtension' do
    include Rack::Test::Methods

    def app
      Sidekiq::Web
    end

    describe 'GET /sidekiq' do
      it 'can display home with history tab' do
        get '/'

        last_response.status.must_equal 200
        last_response.body.must_match /Sidekiq/
        last_response.body.must_match /History/
      end
    end

    describe 'GET /sidekiq/history' do
      before do
        get '/history'
      end

      it 'can display history page without any failures' do
        last_response.status.must_equal 200
        last_response.body.must_match /History/
      end

      describe 'when there are history' do
        it 'should be successful' do
          last_response.status.must_equal 200
        end
      end
    end

    describe 'GET /sidekiq/history/charts.json' do
      before do
        get '/history/charts.json'
      end

      it 'can display history page without any failures' do
        last_response.status.must_equal 200
        response = JSON.parse(last_response.body)

        response['tooltip_template'].must_equal '<%= datasetLabel %> - <%= value %>'
        response['labels'].wont_be_empty

        response['failed_datasets'].wont_be_empty
        response['passed_datasets'].wont_be_empty
      end

      describe 'when there are history' do
        it 'should be successful' do
          last_response.status.must_equal 200
        end
      end
    end
  end
end
