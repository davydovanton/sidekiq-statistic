module Sidekiq
  module Statistic
    class Realtime < Base
      DAYS_PREVIOUS = 30

      def initialize
        @start_date = Time.now.utc.to_date
        @end_date = @start_date - DAYS_PREVIOUS
      end

      def realtime_hash
        Sidekiq.redis do |conn|
          redis_hash = {}
          conn
            .hgetall("#{REDIS_HASH}:realtime:#{Time.now.sec - 1}")
            .each do |keys, value|
              *keys, last = keys.split(':'.freeze)
              keys.inject(redis_hash, &key_or_empty_hash)[last] = value.to_i
            end

          redis_hash
        end
      end
    end
  end
end
