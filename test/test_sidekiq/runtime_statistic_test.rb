require 'minitest_helper'

module Sidekiq
  module History
    describe 'RuntimeStatistic' do
      before do
        Sidekiq.redis(&:flushdb)
      end

      let(:start_date)     { Time.now.utc.to_date }
      let(:end_date)       { start_date - 1 }
      let(:redis_static)   { Sidekiq::History::RedisStatistic.new(start_date, end_date) }
      let(:runtime_static) { Sidekiq::History::RuntimeStatistic.new(redis_static, 'HistoryWorker') }

      describe '#last_runtime' do
        it 'returns last runtime for worker' do
          middlewared {}

          time = DateTime.now
          DateTime.stub :now, time do
            assert_equal time.to_s, runtime_static.last_runtime
          end
        end

        describe 'when jobs were not call' do
          it 'returns nil' do
            assert_equal nil, runtime_static.last_runtime
          end
        end
      end

      describe '#total_runtime' do
        it 'returns totle runtime HistoryWorker' do
          middlewared { sleep 0.2 }

          values = runtime_static.total_runtime
          assert_equal 0.2, values.round(1)
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = runtime_static.total_runtime
            assert_equal 0.0, values
          end
        end
      end

      describe '#average_runtime' do
        it 'returns totle runtime HistoryWorker' do
          middlewared { sleep 0.2 }
          middlewared { sleep 0.1 }
          middlewared { sleep 0.3 }

          values = runtime_static.average_runtime
          assert_equal 0.2, values.round(1)
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = runtime_static.average_runtime
            assert_equal 0.0, values
          end
        end
      end

      describe '#max_runtime' do
        it 'returns max runtime for worker HistoryWorker' do
          middlewared { sleep 0.2 }
          middlewared { sleep 0.3 }
          middlewared { sleep 0.1 }

          values = runtime_static.max_runtime
          assert_equal 0.3, values.round(1)
        end

        describe 'when jobs were not call' do
          it 'returns zero' do
            values = runtime_static.max_runtime
            assert_equal 0.0, values
          end
        end
      end

      describe '#min_runtime' do
        it 'returns max runtime for worker HistoryWorker' do
          middlewared { sleep 0.2 }
          middlewared { sleep 0.3 }
          middlewared { sleep 0.1 }

          values = runtime_static.min_runtime
          assert_equal 0.1, values.round(1)
        end

        describe 'when jobs were not call' do
          it 'returns zero' do
            values = runtime_static.min_runtime
            assert_equal 0.0, values
          end
        end
      end
    end
  end
end
