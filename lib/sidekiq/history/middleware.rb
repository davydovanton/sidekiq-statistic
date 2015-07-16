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

      # read this:
      #   https://medium.com/@stockholmux/store-javascript-objects-in-redis-with-node-js-the-right-way-1e2e89dbbf64
      #   http://www.rediscookbook.org/introduction_to_storing_objects.html
      def save_entry_for_worker(worker_status)
        status = worker_status.dup
        worker = status.delete :class

        Sidekiq.redis do |redis|
          history = "sidekiq:history:#{Time.now.utc.to_date}"

          redis.watch(history) do
            value = Sidekiq.load_json(redis.get(history) || '{}'.freeze)

            redis.multi do |multi|
              if value[worker]
                worker_summary = value[worker].symbolize_keys
                %i[failed passed runtime].each do |stat|
                  status[stat] = worker_summary[stat] + status[stat]
                end
              end

              value[worker] = status

              multi.set history, Sidekiq.dump_json(value)
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
