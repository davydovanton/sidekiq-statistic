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
          Sidekiq.dump_json(workers: statistic.display)
        end

        app.get '/api/statistic/:worker.json' do
          worker_statistic =
            Sidekiq::Statistic::Workers
              .new(*calculate_date_range(params))
              .display_per_day(params[:worker])

          Sidekiq.dump_json(days: worker_statistic)
        end
      end
    end
  end
end
