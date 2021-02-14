# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Filter
      DEFAULT_DAYS_TO_RANGE = 30
      DEFAULT_DATE_FORMAT = '%Y-%m-%d'

      def self.month
        new(from: nil, to: nil)
      end

      def self.yesterday
        new(from: nil, to: nil, days_to_return: 1)
      end

      def initialize(from:, to:, days_to_return: DEFAULT_DAYS_TO_RANGE)
        @from = from ? ::Date.parse(from) : today - days_to_return
        @to = to ? ::Date.parse(to) : today
      end

      def range
        (from..to).map { |date| date.strftime DEFAULT_DATE_FORMAT }
      end

      private

      attr_reader :from, :to

      def today
        @today ||= Time.now.utc.to_date
      end
    end
  end
end
