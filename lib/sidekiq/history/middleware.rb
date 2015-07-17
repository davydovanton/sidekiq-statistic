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

        Sidekiq.redis do |redis|
          redis.watch(REDIS_HASH) do
            passed = redis.hget(REDIS_HASH, "#{worker_key}:passed")
            failed = redis.hget(REDIS_HASH, "#{worker_key}:failed")
            min_time = hget_time(redis, "#{worker_key}:min_time", status)
            max_time = hget_time(redis, "#{worker_key}:max_time", status)
            average_time = hget_time(redis, "#{worker_key}:average_time", status)

            statistic_hash = {
              "#{worker_key}:last_job_status" => status[:last_job_status],
              "#{worker_key}:average_time" => (average_time + status[:time]) / 2,
              "#{worker_key}:last_time" => status[:last_runtime],
              "#{worker_key}:min_time" => [min_time, status[:time]].min,
              "#{worker_key}:max_time" => [max_time, status[:time]].max,
            }

            redis.multi do |multi|
              multi.hset(REDIS_HASH, "#{worker_key}:passed", 0) if passed.nil?
              multi.hset(REDIS_HASH, "#{worker_key}:failed", 0) if failed.nil?
              multi.hincrby REDIS_HASH, "#{worker_key}:#{status[:last_job_status]}", 1
              multi.hincrbyfloat REDIS_HASH, "#{worker_key}:total_time", status[:time]

              statistic_hash.each{ |key, value| multi.hset REDIS_HASH, key, value }
            end
          end || save_entry_for_worker(worker_status)
        end
      end

      def hget_time(redis, key, status)
        (redis.hget(REDIS_HASH, key) || status[:time]).to_f
      end

      # this methos already exist in Sidekiq::Middleware::Server::Logging class
      def elapsed(start)
        (Time.now.utc - start).to_f.round(3)
      end
    end
  end
end
