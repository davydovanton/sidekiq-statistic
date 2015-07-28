require 'minitest_helper'

module Sidekiq
  module History
    describe 'Workers' do
      before do
        Sidekiq.redis(&:flushdb)
      end

      let(:statistic) { Sidekiq::History::Workers.new(1) }

      describe '#number_of_calls' do
        it 'returns success jobs count for worker' do
          10.times { middlewared {} }

          count = statistic.number_of_calls('HistoryWorker')
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

            count = statistic.number_of_calls('HistoryWorker')
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

          count = statistic.number_of_calls('HistoryWorker')
          assert_equal 10, count[:failure]
        end

        describe 'when failure jobs were not call' do
          it 'returns zero' do
            10.times { middlewared {} }

            count = statistic.number_of_calls('HistoryWorker')
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

          count = statistic.number_of_calls('HistoryWorker')

          assert_equal 20, count[:total]
        end

        describe 'when total jobs were not call' do
          it 'returns zero' do
            count = statistic.number_of_calls('HistoryWorker')
            assert_equal 0, count[:failure]
          end
        end
      end
    end
  end
end
