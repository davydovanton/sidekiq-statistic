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

        app.get '/statistic/realtime.json' do
          content_type :json

          statistic = Sidekiq::Statistic::Realtime.new
          Sidekiq.dump_json(realtime: statistic.realtime_hash.to_s)
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
