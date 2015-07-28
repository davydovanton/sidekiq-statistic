module Sidekiq
  module Statistic
    # Heroku have read only file system. See more in this link:
    # https://devcenter.heroku.com/articles/read-only-filesystem
    class LogParser
      def initialize(worker_name)
        @worker_name = worker_name
        @logfile = log_file
      end

      def parse
        return [] unless File.exists?(@logfile)

        File.open(@logfile).map do |line|
          line_hash(line) if line[/\W?#@worker_name\W?/]
        end.compact
      end

      def line_hash(line)
        { color: color(line), text: line.sub(/\n/, '') }
      end

      def color(line)
        case
        when line.include?('done') then 'green'
        when line.include?('start') then 'yellow'
        when line.include?('fail') then 'red'
        end
      end

    private
      def log_file
        Sidekiq.options[:logfile] ||
          Sidekiq.logger.instance_variable_get(:@logdev).filename ||
          Sidekiq::Statistic.configuration.log_file
      end
    end
  end
end
