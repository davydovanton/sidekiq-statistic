module Sidekiq
  module Statistic
    class Charts < Base
      def information_for(type)
        worker_names.reverse.map do |worker|
          color = color_for(worker)
          {
            label: worker,
            fillColor: "rgba(#{color},0.2)",
            strokeColor: "rgba(#{color},0.9)",
            pointColor: "rgba(#{color},0.2)",
            pointStrokeColor: '#fff',
            pointHighlightFill: '#fff',
            pointHighlightStroke: 'rgba(220,220,220,1)',
            data: statistic_for(worker).map{ |val| val.fetch(type, 0) }
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
        @dates ||= statistic_hash.flat_map(&:keys)
      end
    end
  end
end
