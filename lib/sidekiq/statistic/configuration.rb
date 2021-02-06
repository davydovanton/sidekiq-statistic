# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Configuration
      attr_accessor :max_timelist_length

      def initialize
        @max_timelist_length = 250_000
      end
    end
  end
end
