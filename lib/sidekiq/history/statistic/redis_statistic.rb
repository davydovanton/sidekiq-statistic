module Sidekiq
  module History
    class RedisStatistic
      def initialize(start_date, end_date)
        @start_date = start_date
        @end_date = end_date
      end

      def for_worker(worker)
        hash.map{ |h| h.values.first[worker] || {} }
      end

      def worker_names
        @worker_names ||= hash.flat_map{ |h| h.values.first.keys }.uniq
      end

      def hash
        @redis_hash = Sidekiq.redis do |conn|
          redis_hash = {}
          conn
            .hgetall(REDIS_HASH)
            .each do |keys, value|
              *keys, last = keys.split(':'.freeze)
              keys.inject(redis_hash){ |h, k| h[k] || h[k] = {} }[last.to_sym] = to_number(value)
            end

          (@end_date..@start_date).map(&:to_s).map{|key| { key => (redis_hash[key] || {}) } }
        end
      end

    private

      def to_number(value)
        case value
        when /\A[\d.]+\z/ then value.to_f
        when /\A\d+\z/ then value.to_i
        else value
        end
      end
    end
  end
end
