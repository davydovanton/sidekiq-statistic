require 'json'

module Sidekiq
  module Statistic
    module WebApiExtension
      DAFAULT_DAYS = 20

      def self.registered(app)
        app.helpers do
        end

        app.get '/api/statistic.json' do
          content_type :json
          { hello: :world }.to_json
        end

        app.get '/api/statistic/:worker.json' do
          content_type :json

          @name = params[:worker]
          { hello: "@name world" }.to_json
        end
      end
    end
  end
end
