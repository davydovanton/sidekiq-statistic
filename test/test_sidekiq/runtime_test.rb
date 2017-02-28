require 'minitest_helper'

module Sidekiq
  module Statistic
    describe 'Runtime' do
      before { Sidekiq.redis(&:flushdb) }

      let(:statistic)         { Sidekiq::Statistic::Base.new(1) }
      let(:runtime_statistic) { Sidekiq::Statistic::Runtime.new(statistic, 'HistoryWorker') }

      describe '#last_runtime' do
        it 'returns last runtime for worker' do
          middlewared {}

          time = Time.now.utc
          Time.stub :now, time do
            assert_equal time.to_s, runtime_statistic.last_runtime
          end
        end

        describe 'when jobs were not call' do
          it 'returns nil' do
            assert_equal nil, runtime_statistic.last_runtime
          end
        end
      end

      describe '#total_runtime' do
        it 'returns totle runtime HistoryWorker' do
          middlewared { sleep 0.2 }

          values = runtime_statistic.total_runtime
          assert_equal 0.2, values.round(1)
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = runtime_statistic.total_runtime
            assert_equal 0.0, values
          end
        end
      end

      describe '#average_runtime' do
        it 'returns totle runtime HistoryWorker' do
          middlewared { sleep 0.2 }
          middlewared { sleep 0.1 }
          middlewared { sleep 0.3 }

          values = runtime_statistic.average_runtime
          assert_equal 0.2, values.round(1)
        end

        it 'returns precise average runtime HistoryWorker' do
          middlewared { sleep 0.2423 }
          middlewared { sleep 0.1513 }
          middlewared { sleep 0.3125 }
          middlewared { sleep 0.34587 }
          middlewared { sleep 1.12908 }

          values = runtime_statistic.average_runtime
          assert_equal 0.4362, values.round(4)
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = runtime_statistic.average_runtime
            assert_equal 0.0, values
          end
        end

        describe 'when values are strings' do
          it 'should return with precise value' do
            string_test = Sidekiq::Statistic::Runtime.new(statistic, 'JobWorker', { average_time: ['0.2423', '0.1513', '0.3125', '0.34587', '1.12908'] })
            values = string_test.average_runtime
            assert_equal 0.4362, values.round(4)
          end
        end
      end

      describe '#max_runtime' do
        it 'returns max runtime for worker HistoryWorker' do
          middlewared { sleep 0.2 }
          middlewared { sleep 0.3 }
          middlewared { sleep 0.1 }

          values = runtime_statistic.max_runtime
          assert_equal 0.3, values.round(1)
        end

        describe 'when jobs were not call' do
          it 'returns zero' do
            values = runtime_statistic.max_runtime
            assert_equal 0.0, values
          end
        end
      end

      describe '#min_runtime' do
        it 'returns min runtime for worker HistoryWorker' do
          middlewared { sleep 0.2 }
          middlewared { sleep 0.3 }
          middlewared { sleep 0.1 }

          values = runtime_statistic.min_runtime
          assert_equal 0.1, values.round(1)
        end

        describe 'when jobs were not call' do
          it 'returns zero' do
            values = runtime_statistic.min_runtime
            assert_equal 0.0, values
          end
        end
      end
    end
  end
end
