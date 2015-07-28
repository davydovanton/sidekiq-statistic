require 'minitest_helper'

module Sidekiq
  module Statistic
    describe 'Base' do
      before do
        Sidekiq.redis(&:flushdb)
      end

      let(:base_statistic) { Sidekiq::Statistic::Base.new(1) }

      describe '#redis_hash' do
        it 'returns hash for each day' do
          statistic = base_statistic.hash
          assert_equal 2, statistic.size
        end

        it 'returns array with statistic hash for each worker' do
          begin
            middlewared do
              raise StandardError.new('failed')
            end
          rescue
          end
          middlewared {}

          statistic = base_statistic.hash
          worker_hash = statistic.last[Time.now.utc.to_date.to_s]

          assert_equal 1, worker_hash['HistoryWorker'][:failed]
          assert_equal 1, worker_hash['HistoryWorker'][:passed]
        end
      end

      describe '#for_worker' do
        it 'returns array with values for HistoryWorker per day' do
          middlewared {}
          time = Time.now.utc

          Time.stub :now, time do
            values = base_statistic.for_worker('HistoryWorker')
            assert_equal [{}, { passed:1, failed:0, last_job_status: 'passed', average_time: 0.0, total_time: 0.0, last_time: time.to_s, min_time: 0.0, max_time: 0.0 }], values
          end
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = base_statistic.for_worker('HistoryWorker')
            $debugger = true
            assert_equal [{}, {}], values
          end
        end
      end

      describe 'last worker job' do
        it 'returns "passed" for last passed job' do
          begin
            middlewared do
              raise StandardError.new('failed')
            end
          rescue
          end
          middlewared {}

          last_job_status = base_statistic.for_worker('HistoryWorker').last[:last_job_status]
          assert_equal "passed", last_job_status
        end

        it 'returns "failed" for last failed job' do
          middlewared {}
          begin
            middlewared do
              raise StandardError.new('failed')
            end
          rescue
          end

          last_job_status = base_statistic.for_worker('HistoryWorker').last[:last_job_status]
          assert_equal "failed", last_job_status
        end
      end

      describe '#worker_names' do
        it 'returns array with worker names' do
          middlewared {}
          worker_names = base_statistic.worker_names
          assert_equal ['HistoryWorker'], worker_names
        end

        describe 'when jobs were not call' do
          it 'returns empty array' do
            worker_names = base_statistic.worker_names
            assert_equal [], worker_names
          end
        end
      end
    end
  end
end
