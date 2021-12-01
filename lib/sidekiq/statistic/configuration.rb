# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Configuration
      attr_accessor :max_timelist_length

      def initialize
        @max_timelist_length = 250_000
      end

      def max_timelist_length=(value)
        if(value.is_a?(Numeric) && value > 0)
          @max_timelist_length = value
        else
          raise ArgumentError, 'max_timelist_length must be a positive number'
        end
      end

    end
  end
end
