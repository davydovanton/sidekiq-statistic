module Sidekiq
  module Statistic
    # Heroku have read only file system. See more in this link:
    # https://devcenter.heroku.com/articles/read-only-filesystem
    class LogParser
      FILE_LINES_COUNT = 1_000
      def initialize(worker_name)
        @worker_name = worker_name
        @logfile = log_file
      end

      def parse
        return [] unless File.exists?(@logfile)

        File
          .readlines(@logfile)
          .first(FILE_LINES_COUNT)
          .map{ |line| sub_line(line) if line[/\W?#@worker_name\W?/] }
          .compact
      end

      def sub_line(line)
        line
          .sub(/\n/, '')
          .sub(/(JID-[\w]+)/) { jid_tag($1) }
      end

      def jid_tag(jid)
        "<span class=\"statistic__jid js-jid__#{jid[4..-1]}\""\
          "data-target=\".js-jid__#{jid[4..-1]}\" #{jid_style jid}>#{jid}</span>"
      end

      def jid_style(worker_jid)
        return unless worker_jid
        color = Digest::MD5.hexdigest(worker_jid)[4..9]
          .scan(/../).map{ |c| c.to_i(16) }.join ','

        "style=\"background-color: rgba(#{color},0.2);\""
      end

      def color(line)
        case
        when line.include?('done')  then 'green'
        when line.include?('start') then 'yellow'
        when line.include?('fail')  then 'red'
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
