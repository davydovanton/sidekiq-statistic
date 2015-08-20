module Sidekiq
  module Statistic
    class Realtime < Base
      DAYS_PREVIOUS = 30

      def self.charts_initializer
        workers = new.worker_names.map{ |w| Array.new(12, 0).unshift(w) }
        workers << Array.new(12) { |i| (Time.now - i).strftime('%T'.freeze) }.unshift('x'.freeze)
        workers
      end

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
              *keys, last = keys.split(KEY_SEPARATOR)
              keys.inject(redis_hash, &key_or_empty_hash)[last] = value.to_i
            end

          redis_hash
        end
      end

      def statistic(params = {})
        {
          failed: { columns: columns_for('failed'.freeze, params) },
          passed: { columns: columns_for('passed'.freeze, params) }
        }
      end

    private

      def columns_for(status, params = {})
        workers = params['excluded'] ? worker_names - Array(params['excluded']) : worker_names

        workers.map do |worker|
          [worker, realtime.fetch(status, {})[worker] || 0]
        end << axis_array
      end

      def realtime
        @realtime_hash ||= realtime_hash
      end

      def axis_array
        @array ||= ['x', Time.now.strftime('%T'.freeze)]
      end
    end
  end
end
