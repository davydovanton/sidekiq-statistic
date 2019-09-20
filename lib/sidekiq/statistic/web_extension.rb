# frozen_string_literal: true

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

        app.get '/c3.js' do
          [200, { "Content-Type" => "application/javascript" }, [File.read(File.join(view_path, 'c3.js'))]]
        end

        app.get '/realtime_statistic.js' do
          [200, { "Content-Type" => "application/javascript" }, [File.read(File.join(view_path, 'realtime_statistic.js'))]]
        end

        app.get '/statistic.js' do
          [200, { "Content-Type" => "application/javascript" }, [File.read(File.join(view_path, 'statistic.js'))]]
        end

        app.get '/sidekiq-statistic.css' do
          [200, { "Content-Type" => "text/css" }, [File.read(File.join(view_path, 'sidekiq-statistic.css'))]]
        end

        app.get '/statistic' do
          statistic = Sidekiq::Statistic::Workers.new(*calculate_date_range(params))
          @all_workers = statistic.display
          render(:erb, File.read(File.join(view_path, 'statistic.erb')))
        end

        app.get '/statistic/charts.json' do
          charts = Charts.new(*calculate_date_range(params))
          date = {
            format: date_format,
            labels: charts.dates
          }

          json({
            date: date,
            failed_data: charts.information_for(:failed),
            passed_data: charts.information_for(:passed)
          })
        end

        app.get '/statistic/realtime' do
          @workers = Sidekiq::Statistic::Realtime.new.worker_names
          render(:erb, File.read(File.join(view_path, 'realtime.erb')))
        end

        app.get '/statistic/realtime/charts.json' do
          realtime = Sidekiq::Statistic::Realtime.new
          json(realtime.statistic(params))
        end

        app.get '/statistic/realtime/charts_initializer.json' do
          json(Sidekiq::Statistic::Realtime.charts_initializer)
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
