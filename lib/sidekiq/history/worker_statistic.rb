module Sidekiq
  module History
    class WorkerStatistic
      JOB_STATES = [:passed, :failed]

      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def dates
        @dates ||= redis_hash.flat_map(&:keys)
      end

      def display
        workers.map do |worker|
          {
            name: worker,
            number_of_calls: number_of_calls(worker),
            last_runtime: last_runtime(worker),
            total_runtime: total_runtime(worker).round(3),
            average_runtime: average_runtime(worker).round(3),
            max_runtime: max_runtime(worker).round(3)
          }
        end
      end

      def charts(type)
        workers.map do |worker|
          color_hash = random_color_hash
          {
            label: worker,
            fillColor: "rgba(#{color_hash},0.2)",
            strokeColor: "rgba(#{color_hash},0.9)",
            pointColor: "rgba(#{color_hash},0.2)",
            pointStrokeColor: '#fff',
            pointHighlightFill: '#fff',
            pointHighlightStroke: 'rgba(220,220,220,1)',
            data: statistic_for(worker).map{ |val| val.fetch(type, 0) }
          }
        end
      end

      def random_color_hash
        [Random.new.rand(256), Random.new.rand(256), Random.new.rand(256)].join ','
      end

      def workers
        @workers ||= redis_hash.flat_map{ |hash| hash.values.first.keys }.uniq
      end

      def statistic_for(worker)
        redis_hash.map{ |h| h.values.first[worker] || {} }
      end

      def redis_hash
        @redis_hash = Sidekiq.redis do |conn|
          (@end_date..@start_date).map do |date|
            {
              date.to_s => parse_statistic(conn.hgetall("sidekiq:history:#{date}"))
            }
          end
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
        statistic_for(worker)
          .select(&:any?)
          .map{ |hash| hash[state] }.inject(:+) || 0
      end

      def last_runtime(worker)
        statistic_for(worker).map{ |s| s[:last_runtime] }.compact.last
      end

      def total_runtime(worker)
        runtimes_for(worker).inject(:+) || 0.0
      end

      def average_runtime(worker)
        count = runtimes_for(worker).count
        return 0.0 if count == 0
        total_runtime(worker) / count
      end

      def max_runtime(worker)
        runtimes_for(worker).max || 0.0
      end

    private

      def runtimes_for(worker)
        @runtimes ||= statistic_for(worker).flat_map{ |s| s[:runtime] }.compact
      end

      def parse_statistic(hash)
        hash.each do |worker, json|
          hash[worker] = Sidekiq.load_json(json).symbolize_keys
        end
      end
    end
  end
end
