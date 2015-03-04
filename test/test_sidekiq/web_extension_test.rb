require 'minitest_helper'
require 'sidekiq/web'

module Sidekiq
  describe 'WebExtension' do
    include Rack::Test::Methods

    def app
      Sidekiq::Web
    end

    it 'can display home with history tab' do
      get '/'

      last_response.status.must_equal 200
      last_response.body.must_match /Sidekiq/
      last_response.body.must_match /History/
    end

    it 'can display history page without any failures' do
      get '/history'
      last_response.status.must_equal 200
      last_response.body.must_match /History/
    end

    describe 'when there are history' do
      before do
        get '/history'
      end

      it 'should be successful' do
        last_response.status.must_equal 200
      end
    end
  end
end
