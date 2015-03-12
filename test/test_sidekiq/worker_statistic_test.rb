require 'minitest_helper'

module Sidekiq
  module History
    describe 'WorkerStatistic' do
      before do
        Sidekiq.redis(&:flushdb)
      end

      let(:worker_static) { Sidekiq::History::WorkerStatistic.new(1) }

      describe '#dates' do
        it 'returns array with all days' do
          days = worker_static.dates
          assert_equal Time.now.utc.to_date.to_s, days.last
        end
      end

      describe '#workers' do
        it 'returns array with workers' do
          middlewared {}
          days = worker_static.workers
          assert_equal ['HistoryWorker'], days
        end

        describe 'when jobs were not call' do
          it 'returns empty array' do
            days = worker_static.workers
            assert_equal [], days
          end
        end
      end

      describe '#values' do
        it 'returns array with values for HistoryWorker per day' do
          middlewared {}
          time = DateTime.now

          DateTime.stub :now, time do
            values = worker_static.values('HistoryWorker')
            assert_equal [{}, { failed: 0, passed: 1, recently_execution: time.to_s }], values
          end
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = worker_static.values('HistoryWorker')
            assert_equal [{}, {}], values
          end
        end
      end

      describe '#redis_hash' do
        it 'returns hash for each day' do
          history = worker_static.redis_hash
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

          history = Sidekiq::History::WorkerStatistic.new(0).redis_hash
          worker_hash = history.first[Time.now.utc.to_date.to_s]

          assert_equal 1, worker_hash['HistoryWorker'][:failed]
          assert_equal 1, worker_hash['HistoryWorker'][:passed]
        end
      end
    end
  end
end
