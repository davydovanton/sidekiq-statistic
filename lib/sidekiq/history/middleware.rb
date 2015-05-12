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
        start = Time.now.utc

        yield
      rescue StandardError => e
        worker_status[:failed] = 1
        worker_status[:passed] = 0
        worker_status[:last_job_status] = 'failed'.freeze

        raise e
      ensure
        worker_status[:runtime] ||= [elapsed(start)]
        worker_status[:last_runtime] = Time.now.utc
        worker_status[:last_job_status] ||= 'passed'.freeze

        save_entry_for_worker(worker_status, worker)
      end

      def new_status
        # worker.sidekiq_options_hash
        {
          failed: 0,
          passed: 1
        }
      end

      def save_entry_for_worker(worker_status, worker)
        Sidekiq.redis do |redis|
          history = "sidekiq:history:#{Time.now.utc.to_date}"
          value = redis.hget(history, worker.class.to_s)

          if value
            summary = Sidekiq.load_json(value).symbolize_keys
            [:failed, :passed, :runtime].each do |stat|
              worker_status[stat] = summary[stat] + worker_status[stat]
            end
          end

          redis.hset(history, worker.class.to_s, Sidekiq.dump_json(worker_status))
        end
      end

      private

        # this methos already exist in Sidekiq::Middleware::Server::Logging class
        def elapsed(start)
          (Time.now.utc - start).to_f.round(3)
        end
    end
  end
end
