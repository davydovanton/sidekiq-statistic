# frozen_string_literal: true

module Sidekiq
  module Statistic
    # Heroku have read only file system. See more in this link:
    # https://devcenter.heroku.com/articles/read-only-filesystem
    class LogParser
      WORKER_INFO_REGEXP_TEMPLATE = "([\\W]+|^)%{worker_name}([\\W]+|$)"

      def initialize(worker_name)
        @worker_name = worker_name
        @worker_info_regexp = Regexp.compile(WORKER_INFO_REGEXP_TEMPLATE % { worker_name: @worker_name })
        @jid_tag_regexp = Regexp.compile('(JID-[\\w]+)')
      end

      def parse
        return [] unless File.exist?(log_file)
        read_log
          .map { |line| sub_line(line) if line.match(worker_info_regexp) }
          .compact
      end

      def sub_line(line)
        line.sub(/\n/, '').sub(jid_tag_regexp) { jid_tag($1) }
      end

      def jid_tag(jid)
        "<span class=\"statistic__jid js-jid__#{jid[4..-1]}\""\
          "data-target=\".js-jid__#{jid[4..-1]}\" #{jid_style jid}>#{jid}</span>"
      end

      def jid_style(worker_jid)
        return unless worker_jid
        color = Digest::MD5.hexdigest(worker_jid)[4..9]
          .scan(/../).map { |c| c.to_i(16) }.join ','

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

      attr_reader :worker_info_regexp, :jid_tag_regexp

      def log_file
        @log_file ||= Sidekiq.options[:logfile] ||
          Sidekiq.logger.instance_variable_get(:@logdev).filename ||
          Sidekiq::Statistic.configuration.log_file
      end

      def last_log_lines
        Sidekiq::Statistic.configuration.last_log_lines
      end

      def read_log
        file = File.open(log_file, 'r')
        buffer_size = 512
        line_count = 0
        file.seek(0, IO::SEEK_END)
        offset = file.pos
        while line_count <= last_log_lines && offset.positive?
          to_read = (offset - buffer_size).negative? ? offset : buffer_size
          file.seek(offset - to_read)
          data = file.read(to_read)
          data.reverse.each_char do |char|
            if line_count > last_log_lines
              offset += 1
              break
            end
            offset -= 1
            line_count += 1 if char == "\n"
          end
        end
        file.seek(offset)
        file.readlines
      end
    end
  end
end
