require 'json'

module Sidekiq
  module History
    module WebExtension
      def self.registered(app)
        view_path = File.join(File.expand_path('..', __FILE__), 'views')

        app.helpers do
          def formate_date(string)
            Time.parse(string).strftime('%T, %e %B %Y')
          end
        end

        app.get '/history.js' do
          content_type 'text/javascript'
          File.read(File.join(view_path, 'history.js'))
        end

        app.get '/sidekiq-history.css' do
          content_type 'text/css'
          File.read(File.join(view_path, 'sidekiq-history.css'))
        end

        app.get '/history' do
          statistic = Sidekiq::History::Statistic.new(20)
          @workers = statistic.display
          render(:erb, File.read(File.join(view_path, 'history.erb')))
        end

        app.get '/history/charts.json' do
          content_type :json
          charts = Sidekiq::History::Charts.new(20)

          {
            tooltip_template: '<%= datasetLabel %> - <%= value %>',
            labels: charts.dates,
            failed_datasets: charts.information_for(:failed),
            passed_datasets: charts.information_for(:passed)
          }.to_json
        end

        app.get '/history/:worker' do
          @name = params[:worker]
          @worker_statistic = []
          @worker_log =
            Sidekiq::History::LogParser.new(params[:worker]).parse

          render(:erb, File.read(File.join(view_path, 'worker.erb')))
        end
      end
    end
  end
end
