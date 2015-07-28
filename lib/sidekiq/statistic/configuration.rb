module Sidekiq
  module Statistic
    class Configuration
      attr_accessor :log_file

      def initialize
        @log_file = 'log/sidekiq.log'
      end
    end
  end
end
