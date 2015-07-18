module Sidekiq
  module History
    class Middleware
      attr_accessor :msg

      def call(worker, msg, queue, &block)
        call_with_sidekiq_history(worker, msg, queue, &block)
      end

      private

      def call_with_sidekiq_history(worker, msg, queue)
        worker_status = { last_job_status: 'passed'.freeze }
        start = Time.now.utc

        yield
      rescue StandardError => e
        worker_status[:last_job_status] = 'failed'.freeze

        raise e
      ensure
        worker_status[:time] = elapsed(start)
        worker_status[:last_runtime] = Time.now.utc
        worker_status[:class] = msg['wrapped'.freeze] || worker.class.to_s

        save_entry_for_worker worker_status
      end

      def save_entry_for_worker(worker_status)
        status = worker_status.dup
        worker_key = "#{Time.now.utc.to_date}:#{status.delete :class}"
        time_keys = ["#{worker_key}:min_time", "#{worker_key}:max_time", "#{worker_key}:average_time"]

        Sidekiq.redis do |redis|
          min_time, max_time, average_time =
            redis.hmget(REDIS_HASH, time_keys).map{ |v| (v || status[:time]).to_f }
          min_time, max_time = [min_time, max_time, status[:time]].minmax

          statistics = [
            "#{worker_key}:last_job_status", status[:last_job_status],
            "#{worker_key}:average_time", (average_time + status[:time]) / 2,
            "#{worker_key}:last_time", status[:last_runtime],
            "#{worker_key}:min_time", min_time,
            "#{worker_key}:max_time", max_time
          ]

          redis.hincrby REDIS_HASH, "#{worker_key}:#{status[:last_job_status]}", 1
          redis.hincrbyfloat REDIS_HASH, "#{worker_key}:total_time", status[:time]

          redis.hmset REDIS_HASH, statistics
        end
      end

      # this methos already exist in Sidekiq::Middleware::Server::Logging class
      def elapsed(start)
        (Time.now.utc - start).to_f.round(3)
      end
    end
  end
end
