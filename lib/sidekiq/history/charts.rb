module Sidekiq
  module History
    class Charts
      LIVE_SECONDS = 200

      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def live_information
        redis_statistic.worker_names.map do |worker|
          color = color_for(worker)
          {
            label: worker,
            fillColor: "rgba(#{color},0.2)",
            strokeColor: "rgba(#{color},0.9)",
            pointColor: "rgba(#{color},0.2)",
            pointStrokeColor: '#fff',
            pointHighlightFill: '#fff',
            pointHighlightStroke: 'rgba(220,220,220,1)',
            data: (1..LIVE_SECONDS).map{ 0 }
          }
        end
      end

      def stream
        workers_today = redis_statistic.hash.last.values.first

        {
          failed: collect_statuses(workers_today, 'failed'),
          passed: collect_statuses(workers_today, 'passed')
        }
      end

      def collect_statuses(workers, last_job_status)
        workers.map do |_, worker|
          time_now = Time.now.utc
          time_interval = [time_now.to_s, (time_now - 1).to_s, (time_now - 2).to_s]
          next 0 if time_interval.include?(worker[:last_runtime])
          worker[:last_job_status] == last_job_status ? 1 : 0
        end
      end

      def information_for(type)
        redis_statistic.worker_names.map do |worker|
          color = color_for(worker)
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

      def color_for(worker)
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
