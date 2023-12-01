# frozen_string_literal: true

module Sidekiq
  module Statistic
    module Metrics
      class Store
        REDIS_HASH = 'sidekiq:statistic'

        def self.call(metric)
          new(metric).call
        end

        def initialize(metric)
          @metric = metric
          @keys = CacheKeys.new(metric)
        end

        def call
          cache_length = 0

          Sidekiq.redis do |redis|
            cache_length = store_cache_metrics(redis)
            release_cache_allocation(redis, cache_length)
          end
        end

        private

        def store_cache_metrics(redis)
          redis.pipelined do |pipeline|
            pipeline.hincrby(REDIS_HASH, @keys.status, 1)

            pipeline.hset(REDIS_HASH, @keys.last_job_status, @metric.status,
                                  @keys.last_time, @metric.finished_at.to_i,
                                  @keys.queue, @metric.queue)

            pipeline.hincrby(@keys.realtime, @keys.class_name, 1)
            pipeline.expire(@keys.realtime, 2)
          end

          redis.lpush(@keys.timeslist, @metric.duration)
        end

        # The "timeslist" stores an array of decimal numbers representing
        # the time in seconds for a worker duration time.
        #
        # Whenever the "timeslist" exceeds the stipulated max length it is
        # going to remove 25% of the last values inside the array.
        #
        # https://github.com/davydovanton/sidekiq-statistic/issues/73
        def release_cache_allocation(redis, timelist_length)
          max_timelist_length = Sidekiq::Statistic.configuration.max_timelist_length

          if timelist_length > max_timelist_length
            redis.ltrim(@keys.timeslist, 0, (max_timelist_length * 0.75).to_i)
          end
        end
      end
    end
  end
end
