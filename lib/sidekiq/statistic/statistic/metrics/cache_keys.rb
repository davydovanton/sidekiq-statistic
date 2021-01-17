# frozen_string_literal: true

module Sidekiq
  module Statistic
    module Metrics
      class CacheKeys
        def initialize(metric)
          @metric = metric
        end

        def status
          format([key, metric.status])
        end

        def class_name
          format([metric.status, metric.class_name])
        end

        def last_job_status
          format([key, 'last_job_status'])
        end

        def last_time
          format([key, 'last_time'])
        end

        def queue
          format([key, 'queue'])
        end

        def timeslist
          format([key, 'timeslist'])
        end

        def realtime
          format([Store::REDIS_HASH, 'realtime', metric.finished_at.utc.sec])
        end

        private

        attr_reader :metric

        def key
          datetime = metric.finished_at.utc

          format(
            [
              datetime.strftime('%Y-%m-%d'), metric.class_name
            ]
          )
        end

        def format(arr)
          arr.join(':')
        end
      end
    end
  end
end
