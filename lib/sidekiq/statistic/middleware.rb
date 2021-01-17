# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Middleware
      def call(worker, message, queue)
        class_name = message['wrapped'] || worker.class.to_s

        metric = Metric.for(class_name: class_name, arguments: message['args'])
        metric.queue = message['queue'] || queue
        metric.start

        yield
      rescue => e
        metric.fails!

        raise e
      ensure
        metric.finish

        Metrics::Store.call(metric)
      end
    end
  end
end
