# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Charts < Base
      def information_for(type)
        worker_names.reverse.map.with_index do |worker, i|
          color_hex = Helpers::Color.for(worker, :hex)
          index = "data#{i}"
          dataset = [index] + statistic_for(worker).map { |val| val.fetch(type, 0) }
          { worker: worker,
            dataset: dataset,
            color: color_hex }
        end
      end

      def dates
        @dates ||= statistic_hash.flat_map(&:keys)
      end
    end
  end
end
