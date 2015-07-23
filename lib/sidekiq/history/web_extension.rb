require 'json'

module Sidekiq
  module History
    module WebExtension
      DAFAULT_DAYS = 20

      def self.registered(app)
        view_path = File.join(File.expand_path('..', __FILE__), 'views')

        app.helpers do
          def formate_date(string, format = nil)
            string ||= Time.now.utc.to_date.to_s
            Time.parse(string).strftime(format || '%T, %e %B %Y')
          end

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

        app.get '/history.js' do
          content_type 'text/javascript'
          File.read(File.join(view_path, 'history.js'))
        end

        app.get '/sidekiq-history.css' do
          content_type 'text/css'
          File.read(File.join(view_path, 'sidekiq-history.css'))
        end

        app.get '/history' do
          statistic = Sidekiq::History::Statistic.new(*calculate_date_range(params))
          @workers = statistic.display
          render(:erb, File.read(File.join(view_path, 'history.erb')))
        end

        app.get '/history/charts.json' do
          content_type :json
          charts = Sidekiq::History::Charts.new(*calculate_date_range(params))

          {
            tooltip_template: '<%= datasetLabel %> - <%= value %>',
            labels: charts.dates,
            failed_datasets: charts.information_for(:failed),
            passed_datasets: charts.information_for(:passed)
          }.to_json
        end

        app.get '/history/:worker' do
          @name = params[:worker]

          @worker_statistic =
            Sidekiq::History::Statistic.new(*calculate_date_range(params)).display_pre_day(@name)
          @worker_log =
            Sidekiq::History::LogParser.new(@name).parse

          render(:erb, File.read(File.join(view_path, 'worker.erb')))
        end
      end
    end
  end
end
