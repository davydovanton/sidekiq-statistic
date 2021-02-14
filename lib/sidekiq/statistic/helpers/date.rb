# frozen_string_literal: true

module Sidekiq
  module Statistic
    module Helpers
      module Date
        def format_date(date_to_format, format = nil)
          time = date_to_format ? convert_to_date_object(date_to_format) : Time.now
          time.strftime(date_format(format))
        end

        def build_filter_from_request
          from = params['dateFrom']
          to = params['dateTo']

          Filter.new(from: from, to: to)
        end

        def from
          (::Date.today - Filter::DEFAULT_DAYS_TO_RANGE).strftime(date_format)
        end

        def to
          (::Date.today).strftime(date_format)
        end

        module_function

        def date_format(format = nil)
          get_locale.dig('date', 'formats', format || 'default') || '%m/%d/%Y'
        end

        def convert_to_date_object(date)
          date.is_a?(String) ? Time.parse(date) : Time.at(date)
        end
      end
    end
  end
end
