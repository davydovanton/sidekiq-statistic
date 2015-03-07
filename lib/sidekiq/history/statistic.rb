module Sidekiq
  module History
    class Statistic
      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def workers_hash
        Sidekiq.redis do |conn|
          (@end_date..@start_date).map do |date|
            {
              date.to_s => parse_statistic(conn.hgetall("sidekiq:history:#{date}"))
            }
          end
        end
      end

    private
      def parse_statistic(hash)
        hash.each do |worker, json|
          hash[worker] = Sidekiq.load_json(json).symbolize_keys
        end
      end
    end
  end
end
