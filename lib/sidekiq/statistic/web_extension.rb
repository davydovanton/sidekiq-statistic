# frozen_string_literal: true

require 'tilt/erb'
require 'json'

module Sidekiq
  module Statistic
    module WebExtension
      JAVASCRIPT_CONTENT_TYPE = { "Content-Type" => "application/javascript" }
      CSS_CONTENT_TYPE = { "Content-Type" => "text/css" }

      def self.registered(app)
        Sidekiq::Web.settings.locales << File.expand_path(File.dirname(__FILE__) + '/locales')

        app.helpers Helpers::Color
        app.helpers Helpers::Date

        app.get '/c3.js' do
          [200, JAVASCRIPT_CONTENT_TYPE, Views.require_assets('c3.js')]
        end

        app.get '/realtime_statistic.js' do
          [200, JAVASCRIPT_CONTENT_TYPE, Views.require_assets('realtime_statistic.js')]
        end

        app.get '/statistic.js' do
          [200, JAVASCRIPT_CONTENT_TYPE, Views.require_assets('statistic.js')]
        end

        app.get '/ui-datepicker.css' do
          [200, CSS_CONTENT_TYPE, Views.require_assets('styles/ui-datepicker.css')]
        end

        app.get '/common.css' do
          [200, CSS_CONTENT_TYPE, Views.require_assets('styles/common.css')]
        end

        app.get '/sidekiq-statistic-light.css' do
          [200, CSS_CONTENT_TYPE, Views.require_assets('styles/sidekiq-statistic-light.css')]
        end

        app.get '/sidekiq-statistic-dark.css' do
          [200, CSS_CONTENT_TYPE, Views.require_assets('styles/sidekiq-statistic-dark.css')]
        end

        app.get '/statistic' do
          statistic = Workers.new(*calculate_date_range(params))
          
          @all_workers = statistic.display

          render(:erb, Views.require_assets('statistic.erb').first)
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
          @workers = Realtime.new.worker_names
          
          render(:erb, Views.require_assets('realtime.erb').first)
        end

        app.get '/statistic/realtime/charts.json' do
          realtime = Realtime.new

          json(realtime.statistic(params))
        end

        app.get '/statistic/realtime/charts_initializer.json' do
          json(Realtime.charts_initializer)
        end

        app.get '/statistic/:worker' do
          @name = params[:worker]

          @worker_statistic = Workers.new(*calculate_date_range(params))
                                     .display_per_day(@name)

          render(:erb, Views.require_assets('worker.erb').first)
        end
      end
    end
  end
end
