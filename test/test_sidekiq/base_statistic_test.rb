# frozen_string_literal: true

require 'minitest_helper'

module Sidekiq
  module Statistic
    describe 'Base' do
      before { Sidekiq.redis(&:flushdb) }

      let(:base_statistic) { Sidekiq::Statistic::Base.new(1) }

      describe '#redis_hash' do
        it 'returns hash for each day' do
          statistic = base_statistic.statistic_hash
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

          statistic = base_statistic.statistic_hash
          worker_hash = statistic.last[Time.now.utc.to_date.to_s]

          assert_equal 1, worker_hash['HistoryWorker'][:failed]
          assert_equal 1, worker_hash['HistoryWorker'][:passed]
        end

        describe 'after call' do
          it 'deletes timeslist list from redis' do
            middlewared {}

            Sidekiq.redis do |conn|
              assert_equal true, conn.hget(Metrics::Store::REDIS_HASH, "#{Time.now.utc.to_date}:HistoryWorker:total_time").nil?
              assert_equal 1, conn.lrange("#{Time.now.utc.to_date}:HistoryWorker:timeslist", 0, -1).size
            end

            base_statistic.statistic_hash

            Sidekiq.redis do |conn|
              assert_equal false, conn.hget(Metrics::Store::REDIS_HASH, "#{Time.now.utc.to_date}:HistoryWorker:total_time").nil?
              assert_equal 0, conn.lrange("#{Time.now.utc.to_date}:HistoryWorker:timeslist", 0, -1).size
            end
          end
        end
      end

      describe '#statistic_for' do
        it 'returns array with values for HistoryWorker per day' do
          middlewared {}
          time = Time.now.utc

          travel_to time do
            values = base_statistic.statistic_for('HistoryWorker')
            assert_equal [{}, { passed: 1.0, last_job_status: "passed", last_time: time.to_i, queue: "default", average_time: 0.0, min_time: 0.0, max_time: 0.0, total_time: 0.0, failed: 0 }], values
          end
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = base_statistic.statistic_for('HistoryWorker')
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

          last_job_status = base_statistic.statistic_for('HistoryWorker').last[:last_job_status]
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

          last_job_status = base_statistic.statistic_for('HistoryWorker').last[:last_job_status]
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
