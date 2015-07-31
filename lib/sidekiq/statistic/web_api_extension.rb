require 'json'

module Sidekiq
  module Statistic
    module WebApiExtension
      DAFAULT_DAYS = 20

      def self.registered(app)
        app.helpers do
          def calculate_date_range(params)
            if params['dateFrom'] && params['dateTo']
              from = Date.parse(params['dateFrom'])
              to   = Date.parse(params['dateTo'])

              [(to - from).to_i, to]
            else
              [DAFAULT_DAYS]
            end
          end
        end

        app.get '/api/statistic.json' do
          content_type :json

          statistic = Sidekiq::Statistic::Workers.new(*calculate_date_range(params))
          { workers: statistic.display }.to_json
        end

        app.get '/api/statistic/:worker.json' do
          content_type :json

          @name = params[:worker]
          worker_statistic =
            Sidekiq::Statistic::Workers
              .new(*calculate_date_range(params))
              .display_per_day(@name)

          { days: worker_statistic }.to_json
        end
      end
    end
  end
end
