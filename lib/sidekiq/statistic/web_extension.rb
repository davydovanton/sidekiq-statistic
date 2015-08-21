require 'tilt/erb'
require 'json'

module Sidekiq
  module Statistic
    module WebExtension
      def self.registered(app)
        view_path   = File.join(File.expand_path('..', __FILE__), 'views')
        locale_path = File.expand_path(File.dirname(__FILE__) + '/locales')

        Sidekiq::Web.settings.locales << locale_path

        app.helpers WebExtensionHelper

        app.get '/realtime_statistic.js' do
          content_type 'text/javascript'
          File.read(File.join(view_path, 'realtime_statistic.js'))
        end

        app.get '/statistic.js' do
          content_type 'text/javascript'
          File.read(File.join(view_path, 'statistic.js'))
        end

        app.get '/sidekiq-statistic.css' do
          content_type 'text/css'
          File.read(File.join(view_path, 'sidekiq-statistic.css'))
        end

        app.get '/statistic' do
          statistic = Sidekiq::Statistic::Workers.new(*calculate_date_range(params))
          @workers = statistic.display
          render(:erb, File.read(File.join(view_path, 'statistic.erb')))
        end

        app.get '/statistic/charts.json' do
          content_type :json
          charts = Sidekiq::Statistic::Charts.new(*calculate_date_range(params))

          Sidekiq.dump_json(
            tooltip_template: '<%= datasetLabel %> - <%= value %>',
            labels: charts.dates,
            failed_datasets: charts.information_for(:failed),
            passed_datasets: charts.information_for(:passed))
        end

        app.get '/statistic/realtime' do
          @workers = Sidekiq::Statistic::Realtime.new.worker_names
          render(:erb, File.read(File.join(view_path, 'realtime.erb')))
        end

        app.get '/statistic/realtime/charts.json' do
          content_type :json

          realtime = Sidekiq::Statistic::Realtime.new
          Sidekiq.dump_json realtime.statistic(params)
        end

        app.get '/statistic/realtime/charts_initializer.json' do
          content_type :json
          Sidekiq.dump_json Sidekiq::Statistic::Realtime.charts_initializer
        end

        app.get '/statistic/:worker' do
          @name = params[:worker]

          @worker_statistic =
            Sidekiq::Statistic::Workers.new(*calculate_date_range(params)).display_per_day(@name)
          @worker_log =
            Sidekiq::Statistic::LogParser.new(@name).parse

          render(:erb, File.read(File.join(view_path, 'worker.erb')))
        end
      end
    end
  end
end
