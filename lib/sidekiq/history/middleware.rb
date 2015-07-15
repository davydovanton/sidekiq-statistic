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
        worker_status[:class] = msg['wrapped'.freeze] || worker.class.to_s

        save_entry_for_worker worker_status
      end

      def new_status
        {
          failed: 0,
          passed: 1
        }
      end

      def save_entry_for_worker(worker_status)
        status = worker_status.dup
        worker = status.delete :class

        Sidekiq.redis do |redis|
          history = "sidekiq:history:#{Time.now.utc.to_date}"

          redis.watch(history) do
            value = redis.get history

            redis.multi do |multi|
              if value && summary = Sidekiq.load_json(value)[worker]
                summary = summary.symbolize_keys
                [:failed, :passed, :runtime].each do |stat|
                  status[stat] = summary[stat] + status[stat]
                end
              end

              multi.set history, Sidekiq.dump_json(worker => status)
            end
          end || save_entry_for_worker(worker_status)
        end
      end

      # this methos already exist in Sidekiq::Middleware::Server::Logging class
      def elapsed(start)
        (Time.now.utc - start).to_f.round(3)
      end
    end
  end
end
