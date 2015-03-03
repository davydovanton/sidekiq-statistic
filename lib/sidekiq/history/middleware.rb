module Sidekiq
  module History
    class Middleware
      attr_accessor :msg

      def call(worker, msg, queue, &block)
        if worker.kind_of?(Sidetiq::Schedulable)
          call_with_sidekiq_history(worker, msg, queue, &block)
        else
          yield
        end
      end

      private

      def call_with_sidekiq_history(worker, msg, queue)
        worker_history = new_history(worker)

        yield
      rescue StandardError => e
        worker_history[:status] = :failure
        worker_history[:exception] = e.class.to_s
        worker_history[:error] = e.message
        worker_history[:backtrace] = e.backtrace

        raise e
      ensure
        save_entry_for_worker(worker_history, worker)
      end

      def new_history(worker)
        # worker.sidekiq_options_hash
        {
          status: :success,
          error: '',
          exception: '',
          backtrace: '',
          name: worker.class.to_s,
          timestamp: Time.now.iso8601
        }
      end

      def save_entry_for_worker(worker_history, worker)
        Sidekiq.redis do |redis|
          history = "sidekiq:history"
          redis.lpush(history, Sidekiq.dump_json(worker_history))
        end
      end
    end
  end
end
