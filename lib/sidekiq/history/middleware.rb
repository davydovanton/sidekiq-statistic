module Sidekiq
  module History
    class Middleware
      SERVESLIST = 'sidekiq:history:serveslist'.freeze

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
        worker_status[:class] = worker.class.to_s

        save_entry_for_worker worker_status
      end

      def new_status
        {
          failed: 0,
          passed: 1
        }
      end

      #
      # Reed more about rpoplpush here (also reed about brpoplpush):
      #   http://redis.io/commands/rpoplpush

      def push_to_serveslist(worker_status)
        Sidekiq.redis do |redis|
          # atomic push to list
          redis.hset(SERVESLIST, Sidekiq.dump_json(worker_status))
        end
      end

      # run unique servise_actor. Reed celluloid documentation
      def servise_actor
        Sidekiq.redis do |redis|
          # atomig get from list
          worker_status = Sidekiq.load_json(redis.hget(SERVESLIST)).symbolize_keys
          worker = worker_status.delete :class

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

        after(0.1) do
          servise_actor
        end
      end

      def save_entry_for_worker(worker_status)
        worker = worker_status.delete :class

        Sidekiq.redis do |redis|
          history = "sidekiq:history:#{Time.now.utc.to_date}"
          value = redis.hget(history, worker)

          if value
            summary = Sidekiq.load_json(value).symbolize_keys
            [:failed, :passed, :runtime].each do |stat|
              worker_status[stat] = summary[stat] + worker_status[stat]
            end
          end

          redis.hset(history, worker, Sidekiq.dump_json(worker_status))
        end
      end

      # this methos already exist in Sidekiq::Middleware::Server::Logging class
      def elapsed(start)
        (Time.now.utc - start).to_f.round(3)
      end
    end
  end
end
