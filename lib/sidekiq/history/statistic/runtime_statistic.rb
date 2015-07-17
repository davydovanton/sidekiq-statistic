module Sidekiq
  module History
    class RuntimeStatistic
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
        values.map{ |s| s[:max_time] }.compact.max || 0.0
      end

      def min_runtime
        values.map{ |s| s[:min_time] }.compact.min || 0.0
      end

      def last_runtime
        @redis_statistic
          .for_worker(@worker).last[:last_time]
      end

      def total_runtime
        values.map{ |s| s[:total_time] }.compact.inject(:+) || 0.0
      end

      def average_runtime
        averages = values.map{ |s| s[:average_time] }.compact
        count = averages.count
        return 0.0 if count == 0
        averages.inject(:+) / count
      end

    private

      def values
        @values ||= @redis_statistic.for_worker(@worker)
      end
    end
  end
end
