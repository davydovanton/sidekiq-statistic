module Sidekiq
  module History
    class Middleware
      attr_accessor :msg

      def call(worker, msg, queue, &block)
        call_with_sidekiq_history(worker, msg, queue, &block)
      end

      private

      def call_with_sidekiq_history(worker, msg, queue)
        worker_sratus = new_status

        yield
      rescue StandardError => e
        worker_sratus[:failed] = 1
        worker_sratus[:passed] = 0

        raise e
      ensure
        save_entry_for_worker(worker_sratus, worker)
      end

      def new_status
        # worker.sidekiq_options_hash
        {
          failed: 0,
          passed: 1
        }
      end

      def save_entry_for_worker(worker_sratus, worker)
        Sidekiq.redis do |redis|
          history = "sidekiq:history:#{Time.now.utc.to_date}"
          value = redis.hget(history, worker.class.to_s)

          if value
            summary = Sidekiq.load_json(value).symbolize_keys
            worker_sratus[:failed] = worker_sratus[:failed] + summary[:failed]
            worker_sratus[:passed] = worker_sratus[:passed] + summary[:passed]
          end

          redis.hset(history, worker.class.to_s, Sidekiq.dump_json(worker_sratus))
        end
      end
    end
  end
end
