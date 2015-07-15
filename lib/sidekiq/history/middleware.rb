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
        worker_status[:class] = if msg['wrapped']
          Sidekiq::Job.new(msg).display_class
        else
          worker.class.to_s
        end
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
            if value && Sidekiq.load_json(value)[worker]
              summary = Sidekiq.load_json(value)[worker].symbolize_keys
              [:failed, :passed, :runtime].each do |stat|
                status[stat] = summary[stat] + status[stat]
              end
            end
            hash_value = Sidekiq.load_json(value) if value
            hash_value ||= {}

            new_value = hash_value.merge({worker => status})
            multi.set(history, Sidekiq.dump_json(new_value))
          end
          end || save_entry_for_worker(worker_status)
        end
      end

      # this methods already exist in Sidekiq::Middleware::Server::Logging class
      def elapsed(start)
        (Time.now.utc - start).to_f.round(3)
      end
    end
  end
end
