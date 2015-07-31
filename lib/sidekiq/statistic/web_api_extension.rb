require 'json'

module Sidekiq
  module Statistic
    module WebApiExtension
      def self.registered(app)
        app.helpers WebExtensionHelper

        app.before '/api/*' do
          content_type :json
        end

        app.get '/api/statistic.json' do
          statistic = Sidekiq::Statistic::Workers.new(*calculate_date_range(params))
          { workers: statistic.display }.to_json
        end

        app.get '/api/statistic/:worker.json' do
          worker_statistic =
            Sidekiq::Statistic::Workers
              .new(*calculate_date_range(params))
              .display_per_day(params[:worker])

          { days: worker_statistic }.to_json
        end
      end
    end
  end
end
