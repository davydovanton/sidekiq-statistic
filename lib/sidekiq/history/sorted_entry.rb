module Sidekiq
  module History
    class SortedEntry
      def history
        { history: redis_data[0] }
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
