# frozen_string_literal: true

require 'json'

module Sidekiq
  module Statistic
    module WebApiExtension
      def self.registered(app)
        app.helpers Helpers::Color
        app.helpers Helpers::Date

        app.before '/api/*' do
          type = :json
        end

        app.get '/api/statistic.json' do
          statistic = Sidekiq::Statistic::Workers.new(build_filter_from_request)
          Sidekiq.dump_json(workers: statistic.display)
        end

        app.get '/api/statistic/:worker.json' do
          worker_statistic =
            Sidekiq::Statistic::Workers
              .new(build_filter_from_request)
              .display_per_day(params[:worker])

          Sidekiq.dump_json(days: worker_statistic)
        end
      end
    end
  end
end
