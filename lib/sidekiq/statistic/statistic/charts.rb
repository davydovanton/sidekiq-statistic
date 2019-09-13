# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Charts < Base
      def information_for(type)
        worker_names.reverse.map do |worker|
          color = color_for(worker)
          data = [worker]
          statistic_for(worker).each { |val| data << val.fetch(type, 0) }
          data
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
