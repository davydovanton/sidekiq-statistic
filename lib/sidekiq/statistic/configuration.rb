module Sidekiq
  module Statistic
    class Configuration
      attr_accessor :log_file, :log_file_lines_count

      def initialize
        @log_file = 'log/sidekiq.log'
        @log_file_lines_count = 1000
      end
    end
  end
end
