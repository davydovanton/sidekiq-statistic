module Sidekiq
  module History
    class Statistic
      JOB_STATES = [:passed, :failed]

      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def display
        redis_statistic.worker_names.map do |worker|
          {
            name: worker,
            number_of_calls: number_of_calls(worker),
            runtime: runtime_statistic(worker).values_hash
          }
        end
      end

      def number_of_calls(worker)
        number_of_calls = JOB_STATES.map{ |state| number_of_calls_for state, worker }

        {
          success: number_of_calls.first,
          failure: number_of_calls.last,
          total: number_of_calls.inject(:+)
        }
      end

      def number_of_calls_for(state, worker)
        redis_statistic.for_worker(worker)
          .select(&:any?)
          .map{ |hash| hash[state] }.inject(:+) || 0
      end

      def runtime_statistic(worker)
        RuntimeStatistic.new(redis_statistic, worker)
      end

      def redis_statistic
        RedisStatistic.new(@start_date, @end_date)
      end
    end
  end
end
