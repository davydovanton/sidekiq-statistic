module Sidekiq
  module History
    class RuntimeStatistic
      def initialize(redis_statistic, worker)
        @redis_statistic = redis_statistic
        @worker = worker
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
        values.max || 0.0
      end

      def min_runtime
        values.min || 0.0
      end

      def last_runtime
        @redis_statistic
          .for_worker(@worker)
          .map{ |s| s[:last_runtime] }
          .compact.last
      end

      def total_runtime
        values.inject(:+) || 0.0
      end

      def average_runtime
        count = values.count
        return 0.0 if count == 0
        total_runtime / count
      end

    private

      def values
        @values ||=
          @redis_statistic
            .for_worker(@worker)
            .flat_map{ |s| s[:runtime] }
            .compact
      end
    end
  end
end
