# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Configuration
      attr_accessor :log_file, :last_log_lines, :max_timelist_length

      def initialize
        @log_file = 'log/sidekiq.log'
        @last_log_lines = 1_000
        @max_timelist_length = 250_000
      end
    end
  end
end
