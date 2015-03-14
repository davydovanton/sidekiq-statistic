module Sidekiq
  module History
    class Middleware
      attr_accessor :msg

      def call(worker, msg, queue, &block)
        call_with_sidekiq_history(worker, msg, queue, &block)
      end

      private

      def call_with_sidekiq_history(worker, msg, queue)
        worker_status = new_status

        yield
      rescue StandardError => e
        worker_status[:failed] = 1
        worker_status[:passed] = 0
        worker_status[:runtime] = 0

        raise e
      ensure
        save_entry_for_worker(worker_status, worker)
      end

      def new_status
        # worker.sidekiq_options_hash
        {
          failed: 0,
          passed: 1,
          last_runtime: DateTime.now
        }
      end

      def save_entry_for_worker(worker_status, worker)
        Sidekiq.redis do |redis|
          history = "sidekiq:history:#{Time.now.utc.to_date}"
          value = redis.hget(history, worker.class.to_s)

          if value
            summary = Sidekiq.load_json(value).symbolize_keys
            worker_status[:failed] = worker_status[:failed] + summary[:failed]
            worker_status[:passed] = worker_status[:passed] + summary[:passed]
          end

          redis.hset(history, worker.class.to_s, Sidekiq.dump_json(worker_status))
        end
      end
    end
  end
end
