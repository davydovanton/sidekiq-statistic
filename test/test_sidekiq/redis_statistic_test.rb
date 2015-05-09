require 'minitest_helper'

module Sidekiq
  module History
    describe 'RedisStatistic' do
      before do
        Sidekiq.redis(&:flushdb)
      end

      let(:start_date)   { Time.now.utc.to_date }
      let(:end_date)     { start_date - 1 }
      let(:redis_static) { Sidekiq::History::RedisStatistic.new(start_date, end_date) }

      describe '#redis_hash' do
        it 'returns hash for each day' do
          history = redis_static.hash
          assert_equal 2, history.size
        end

        it 'returns array with history hash for each worker' do
          begin
            middlewared do
              raise StandardError.new('failed')
            end
          rescue
          end
          middlewared {}

          history = redis_static.hash
          worker_hash = history.last[Time.now.utc.to_date.to_s]

          assert_equal 1, worker_hash['HistoryWorker'][:failed]
          assert_equal 1, worker_hash['HistoryWorker'][:passed]
        end
      end

      describe '#for_worker' do
        it 'returns array with values for HistoryWorker per day' do
          middlewared {}
          time = Time.now.utc

          Time.stub :now, time do
            values = redis_static.for_worker('HistoryWorker')
            assert_equal [{}, { failed: 0, passed: 1, runtime: [0.0], last_runtime: time.to_s }], values
          end
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = redis_static.for_worker('HistoryWorker')
            assert_equal [{}, {}], values
          end
        end
      end

      describe '#worker_names' do
        it 'returns array with worker names' do
          middlewared {}
          worker_names = redis_static.worker_names
          assert_equal ['HistoryWorker'], worker_names
        end

        describe 'when jobs were not call' do
          it 'returns empty array' do
            worker_names = redis_static.worker_names
            assert_equal [], worker_names
          end
        end
      end
    end
  end
end
