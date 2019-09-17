# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Charts < Base
      def information_for(type)
        worker_names.reverse.map.with_index do |worker, i|
          color_hex = rgb_to_hex(color_for(worker))
          index = "data#{i}"
          dataset = [index] + statistic_for(worker).map { |val| val.fetch(type, 0) }
          { worker: worker,
            dataset: dataset,
            color: color_hex }
        end
      end

      def color_for(worker)
        Digest::MD5.hexdigest(worker)[0..5]
          .scan(/../)
          .map{ |color| color.to_i(16) }
          .join ','
      end

      def rgb_to_hex(rgb)
        '#' + rgb.split(',').map { |v| v.to_i.to_s(16).rjust(2, '0').upcase }.join
      end

      def dates
        @dates ||= statistic_hash.flat_map(&:keys)
      end
    end
  end
end
