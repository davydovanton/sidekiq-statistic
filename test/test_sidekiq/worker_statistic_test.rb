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

      describe '#last_runtime' do
        it 'returns last runtime for worker' do
          middlewared {}

          time = DateTime.now
          DateTime.stub :now, time do
            values = worker_static.statistic_for('HistoryWorker')
            assert_equal time.to_s, worker_static.last_runtime('HistoryWorker')
          end
        end

        describe 'when jobs were not call' do
          it 'returns nil' do
            assert_equal nil, worker_static.last_runtime('HistoryWorker')
          end
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
            values = worker_static.statistic_for('HistoryWorker')
            assert_equal [{}, { failed: 0, passed: 1, last_runtime: time.to_s }], values
          end
        end

        describe 'when jobs were not call' do
          it 'returns array with empty values' do
            values = worker_static.statistic_for('HistoryWorker')
            assert_equal [{}, {}], values
          end
        end
      end

      describe '#number_of_calls' do
        it 'returns success jobs count for worker' do
          10.times { middlewared {} }

          count = worker_static.number_of_calls('HistoryWorker')
          assert_equal 10, count[:success]
        end

        describe 'when success jobs were not call' do
          it 'returns zero' do
            10.times do
              begin
                middlewared do
                  raise StandardError.new('failed')
                end
              rescue
              end
            end

            count = worker_static.number_of_calls('HistoryWorker')
            assert_equal 0, count[:success]
          end
        end

        it 'returns failure jobs count for worker' do
          10.times do
            begin
              middlewared do
                raise StandardError.new('failed')
              end
            rescue
            end
          end

          count = worker_static.number_of_calls('HistoryWorker')
          assert_equal 10, count[:failure]
        end

        describe 'when failure jobs were not call' do
          it 'returns zero' do
            10.times { middlewared {} }

            count = worker_static.number_of_calls('HistoryWorker')
            assert_equal 0, count[:failure]
          end
        end

        it 'returns total jobs count for worker' do
          10.times do
            middlewared {}

            begin
              middlewared do
                raise StandardError.new('failed')
              end
            rescue
            end
          end

          count = worker_static.number_of_calls('HistoryWorker')
          assert_equal 20, count[:total]
        end

        describe 'when total jobs were not call' do
          it 'returns zero' do
            count = worker_static.number_of_calls('HistoryWorker')
            assert_equal 0, count[:failure]
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
