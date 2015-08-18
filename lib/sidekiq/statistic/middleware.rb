module Sidekiq
  module Statistic
    class Middleware
      attr_accessor :msg

      def call(worker, msg, queue, &block)
        call_with_sidekiq_Statistic(worker, msg, queue, &block)
      end

      private

      def call_with_sidekiq_Statistic(worker, msg, queue)
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
        realtime_hash = "#{REDIS_HASH}:realtime:#{Time.now.sec}"
        worker_key = "#{Time.now.utc.to_date}:#{status.delete :class}"

        Sidekiq.redis do |redis|
          statistics = [
            "#{worker_key}:last_job_status", status[:last_job_status],
            "#{worker_key}:last_time", status[:last_runtime]
          ]

          redis.hincrby REDIS_HASH, "#{worker_key}:#{status[:last_job_status]}", 1

          redis.hmset REDIS_HASH, statistics
          redis.lpush "#{worker_key}:timeslist", status[:time]

          redis.hincrby realtime_hash, "#{status[:last_job_status]}:#{worker_status[:class]}", 1
          redis.expire realtime_hash, 2
        end
      end

      # this methos already exist in Sidekiq::Middleware::Server::Logging class
      def elapsed(start)
        (Time.now.utc - start).to_f.round(3)
      end
    end
  end
end
