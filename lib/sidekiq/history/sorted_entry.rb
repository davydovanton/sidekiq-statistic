module Sidekiq
  module History
    class SortedEntry
      def history
        redis_data.first
          .map { |worker| Sidekiq.load_json(worker).symbolize_keys }
      end

    private

      def redis_data
        Sidekiq.redis do |conn|
          conn.pipelined do
            conn.lrange('sidekiq:history'.freeze, 0, -1)
          end
        end
      end
    end
  end
end
