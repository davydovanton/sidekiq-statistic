# frozen_string_literal: true
require 'json'

module Sidekiq
  module Statistic
    module WebExtensionHelper
      DAFAULT_DAYS = 20

      def format_date(date_to_format, format = nil)
        time = date_to_format ? convert_to_date_object(date_to_format) : Time.now
        time.strftime(format || '%T, %e %B %Y')
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

      private

      def convert_to_date_object(date)
        date.is_a?(String) ? Time.parse(date) : Time.at(date)
      end  
    end
  end
end
