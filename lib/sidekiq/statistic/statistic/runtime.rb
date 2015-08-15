module Sidekiq
  module Statistic
    class Runtime
      def initialize(redis_statistic, worker, values = nil)
        @redis_statistic = redis_statistic
        @worker = worker
        @values = values
      end

      def values_hash
        {
          last: last_runtime,
          max: max_runtime.round(3),
          min: min_runtime.round(3),
          average: average_runtime.round(3),
          total: total_runtime.round(3)
        }
      end

      def max_runtime
        values(:timeslist).max || 0.0
      end

      def min_runtime
        values(:timeslist).min || 0.0
      end

      def last_runtime
        @redis_statistic.statistic_for(@worker).last[:last_time]
      end

      def total_runtime
        values(:timeslist).inject(:+) || 0.0
      end

      def average_runtime
        averages = values(:timeslist)
        count = averages.count
        return 0.0 if count == 0
        averages.inject(:+) / count
      end

    private

      def values(key)
        @values ||= @redis_statistic.statistic_for(@worker)
        @values.flat_map{ |s| s[key] }.compact
      end
    end
  end
end
