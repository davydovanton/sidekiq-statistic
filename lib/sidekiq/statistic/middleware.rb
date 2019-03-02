# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Middleware
      attr_accessor :msg

      def call(worker, msg, queue)
        worker_status = { last_job_status: 'passed' }
        start = Time.now

        yield
      rescue => e
        worker_status[:last_job_status] = 'failed'

        raise e
      ensure
        finish = Time.now
        worker_status[:queue] = msg['queue']
        worker_status[:last_runtime] = finish.utc.to_i
        worker_status[:time] = (finish - start).to_f.round(3)
        worker_status[:class] = msg['wrapped'] || worker.class.to_s
        if worker_status[:class] == 'ActionMailer::DeliveryJob'
          worker_status[:class] = msg['args'].first['arguments'].first
        end

        save_entry_for_worker worker_status
      end

      def save_entry_for_worker(worker_status)
        status = worker_status.dup
        time = Time.at(worker_status[:last_runtime]).utc
        realtime_hash = "#{REDIS_HASH}:realtime:#{time.sec}"
        worker_key = "#{time.strftime "%Y-%m-%d"}:#{status.delete :class}"
        timeslist_key = "#{worker_key}:timeslist"
        times_list_length = nil
        max_timelist_length = Sidekiq::Statistic.configuration.max_timelist_length

        Sidekiq.redis do |redis|
          redis.pipelined do
            redis.hincrby REDIS_HASH, "#{worker_key}:#{status[:last_job_status]}", 1
            redis.hmset REDIS_HASH, "#{worker_key}:last_job_status", status[:last_job_status],
                                    "#{worker_key}:last_time", status[:last_runtime],
                                    "#{worker_key}:queue", status[:queue]
            times_list_length = redis.lpush timeslist_key, status[:time]

            redis.hincrby realtime_hash, "#{status[:last_job_status]}:#{worker_status[:class]}", 1
            redis.expire realtime_hash, 2
          end

          # Drop the oldest 25% of timing values if required to prevent Redis memory issues
          if times_list_length.value > max_timelist_length
            redis.ltrim(timeslist_key, 0, (max_timelist_length * 0.75).to_i)
          end
        end
      end

    end
  end
end
