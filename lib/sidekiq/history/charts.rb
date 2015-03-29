module Sidekiq
  module History
    class Charts
      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def information_for(type)
        redis_statistic.worker_names.map do |worker|
          color = color(worker)
          {
            label: worker,
            fillColor: "rgba(#{color},0.2)",
            strokeColor: "rgba(#{color},0.9)",
            pointColor: "rgba(#{color},0.2)",
            pointStrokeColor: '#fff',
            pointHighlightFill: '#fff',
            pointHighlightStroke: 'rgba(220,220,220,1)',
            data: redis_statistic.for_worker(worker).map{ |val| val.fetch(type, 0) }
          }
        end
      end

      def color(worker)
        Digest::MD5.hexdigest(worker)[0..5]
          .scan(/../)
          .map{ |color| color.to_i(16) }
          .join ','
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
