module Sidekiq
  module History
    class Charts
      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def information_for(type)
        redis_statistic.worker_names.map do |worker|
          color_hash = random_color_hash
          {
            label: worker,
            fillColor: "rgba(#{color_hash},0.2)",
            strokeColor: "rgba(#{color_hash},0.9)",
            pointColor: "rgba(#{color_hash},0.2)",
            pointStrokeColor: '#fff',
            pointHighlightFill: '#fff',
            pointHighlightStroke: 'rgba(220,220,220,1)',
            data: redis_statistic.for_worker(worker).map{ |val| val.fetch(type, 0) }
          }
        end
      end

      def random_color_hash
        [Random.new.rand(256), Random.new.rand(256), Random.new.rand(256)].join ','
      end

      def dates
        @dates ||= redis_statistic.hash.flat_map(&:keys)
      end

    private

      def redis_statistic
        RedisStatistic.new(@start_date, @end_date)
      end
    end
  end
end
