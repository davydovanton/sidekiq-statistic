module Sidekiq
  module Statistic
    class Configuration
      attr_accessor :log_file, :last_log_lines

      def initialize
        @log_file = 'log/sidekiq.log'
        @last_log_lines = 1_000
      end
    end
  end
end
