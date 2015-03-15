module Sidekiq
  module History
    # Heroku have read only file system. See more in this link:
    # https://devcenter.heroku.com/articles/read-only-filesystem
    class LogParser
      def initialize(worker_name)
        @worker_name = worker_name
        @logfile = Sidekiq.options[:logfile] || 'log/sidekiq.log'
      end

      def parse
        File.open(@logfile).map do |line|
          line if line[/\W#@worker_name\W/]
        end
      end
    end
  end
end
