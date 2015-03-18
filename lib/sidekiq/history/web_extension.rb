require 'json'

module Sidekiq
  module History
    module WebExtension
      def self.registered(app)
        view_path = File.join(File.expand_path('..', __FILE__), 'views')

        app.helpers do
        end

        app.get '/style.css' do
          File.read(File.join(view_path, 'style.css'))
        end

        app.get '/history' do
          worker_statistic = Sidekiq::History::WorkerStatistic.new(20)
          @workers = worker_statistic.display
          render(:erb, File.read(File.join(view_path, 'history.erb')))
        end

        app.get '/history/charts.json' do
          content_type :json
          worker_statistic = Sidekiq::History::WorkerStatistic.new(20)

          {
            tooltip_template: '<%= datasetLabel %> - <%= value %>',
            labels: worker_statistic.dates,
            failed_datasets: worker_statistic.charts(:failed),
            passed_datasets: worker_statistic.charts(:passed)
          }.to_json
        end

        app.get '/history/:worker' do
          @name = params[:worker]
          @worker_log =
            Sidekiq::History::LogParser.new(params[:worker]).parse

          render(:erb, File.read(File.join(view_path, 'worker.erb')))
        end
      end
    end
  end
end
