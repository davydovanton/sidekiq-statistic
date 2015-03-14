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
        start = Time.now

        yield
      rescue StandardError => e
        worker_status[:failed] = 1
        worker_status[:passed] = 0
        worker_status[:runtime] = 0.0

        raise e
      ensure
        worker_status[:runtime] ||= elapsed start

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
            [:failed, :passed, :runtime].each do |stat|
              worker_status[stat] = worker_status[stat] + summary[stat]
            end
          end

          redis.hset(history, worker.class.to_s, Sidekiq.dump_json(worker_status))
        end
      end

      private

        # this methos already exist in Sidekiq::Middleware::Server::Logging class
        def elapsed(start)
          (Time.now - start).to_f.round(3)
        end
    end
  end
end
