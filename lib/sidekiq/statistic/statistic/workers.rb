module Sidekiq
  module Statistic
    class Workers < Base
      JOB_STATES = [:passed, :failed]

      def display
        worker_names.map do |worker|
          {
            name: worker,
            last_job_status: last_job_status_for(worker),
            number_of_calls: number_of_calls(worker),
            queue: last_queue(worker),
            runtime: runtime_statistic(worker).values_hash
          }
        end
      end

      def display_per_day(worker_name)
        statistic_hash.flat_map do |day|
          day.reject{ |_, workers| workers.empty? }.map do |date, workers|
            worker_data = workers[worker_name]
            next unless worker_data

            {
              date: date,
              failure: worker_data[:failed],
              success: worker_data[:passed],
              total: worker_data[:failed] + worker_data[:passed],
              last_job_status: worker_data[:last_job_status],
              runtime: runtime_for_day(worker_name, worker_data)
            }
          end
        end.compact.reverse
      end

      def runtime_for_day(worker_name, worker_data)
        runtime_statistic(worker_name, worker_data)
          .values_hash
          .merge!(last: worker_data[:last_time])
      end

      def number_of_calls(worker)
        number_of_calls = JOB_STATES.map{ |state| number_of_calls_for state, worker }

        {
          success: number_of_calls.first,
          failure: number_of_calls.last,
          total: number_of_calls.inject(:+)
        }
      end

      def number_of_calls_for(state, worker)
        statistic_for(worker)
          .select(&:any?)
          .map{ |hash| hash[state] }.inject(:+) || 0
      end

      def last_job_status_for(worker)
        statistic_for(worker)
          .select(&:any?)
          .last[:last_job_status]
      end

      def last_queue(worker)
        statistic_for(worker).last[:queue]
      end

      def runtime_statistic(worker, values = nil)
        Runtime.new(self, worker, values)
      end
    end
  end
end
