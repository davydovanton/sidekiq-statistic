module Sidekiq
  module History
    class WorkerStatistic
      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def dates
        @dates ||= redis_hash.flat_map(&:keys)
      end

      def charts(type, options = {})
        workers.map do |worker|
          color_hash = [Random.new.rand(256), Random.new.rand(256), Random.new.rand(256)].join ','
          {
            label: worker,
            fillColor: "rgba(#{color_hash},0.2)",
            strokeColor: "rgba(#{color_hash},0.9)",
            pointColor: "rgba(#{color_hash},0.2)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: values(worker).map{ |val| val.fetch(type, 0) }
          }
        # TODO: remove #to_json method
        end.to_json
      end

      def workers
        @workers ||= redis_hash.flat_map{ |hash| hash.values.first.keys }.uniq
      end

      def values(worker)
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

    private

      def parse_statistic(hash)
        hash.each do |worker, json|
          hash[worker] = Sidekiq.load_json(json).symbolize_keys
        end
      end
    end
  end
end
