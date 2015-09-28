module Sidekiq
  module Statistic
    class Base
      KEY_SEPARATOR = /(?<!:):(?!:)/.freeze

      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def statistic_for(worker)
        statistic_hash.map{ |h| h.values.first[worker] || {} }
      end

      def worker_names
        @worker_names ||= statistic_hash.flat_map{ |h| h.values.first.keys }.uniq.sort
      end

      def statistic_hash
        @redis_hash ||= Sidekiq.redis do |conn|
          redis_hash = {}
          get_statistic_hash(conn, redis_hash)
          update_time_values(conn, redis_hash)
          desired_dates.map { |key| result_hash(redis_hash, key) }
        end
      end

    private

      def get_statistic_hash(conn, redis_hash)
        conn
          .hgetall(REDIS_HASH)
          .each do |keys, value|
            *keys, last = keys.split(KEY_SEPARATOR)
            keys.inject(redis_hash, &key_or_empty_hash)[last.to_sym] = to_number(value)
          end
      end

      def key_or_empty_hash
        ->(h, k) { h[k] || h[k] = {} }
      end

      def desired_dates
        (@end_date..@start_date).map { |date| date.strftime "%Y-%m-%d" }
      end

      def result_hash(redis_hash, key)
        redis_hash.fetch(key, {}).each { |_, v| update_hash_statments v }
        { key => (redis_hash[key] || {}) }
      end

      def update_hash_statments(hash)
        hash[:passed] ||= 0
        hash[:failed] ||= 0
      end

      def to_number(value)
        case value
        when /\A[\d.]+\z/ then value.to_f
        when /\A\d+\z/ then value.to_i
        else value
        end
      end

      def update_time_values(conn, redis_hash)
        redis_hash.each do |time, workers|
          workers.each do |worker, _|
            worker_key = "#{time}:#{worker}"

            timeslist, _ = conn.multi do |multi|
              multi.lrange("#{worker_key}:timeslist", 0, -1)
              multi.del("#{worker_key}:timeslist")
            end

            timeslist.map!(&:to_f)
            redis_hash[time][worker].merge! time_hash(timeslist, worker_key)
          end
        end
      end

      def time_hash(timeslist, worker_key)
        return {} if timeslist.empty?
        statistics = time_statistics(timeslist)

        Sidekiq.redis do |redis|
          redis.hmset REDIS_HASH,
            statistics.flat_map{ |(k, v)| ["#{worker_key}:#{k}", v] }
        end

        statistics
      end

      def time_statistics(timeslist)
        total = timeslist.inject(:+)

        {
          average_time: total / timeslist.count,
          min_time: timeslist.min,
          max_time: timeslist.max,
          total_time: total
        }
      end
    end
  end
end
