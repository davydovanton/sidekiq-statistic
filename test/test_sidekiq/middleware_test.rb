require 'minitest_helper'

module Sidekiq
  module History
    describe 'Middleware' do
      def to_number(i)
        i.match('\.').nil? ? Integer(i) : Float(i) rescue i.to_s
      end

      before { Sidekiq.redis(&:flushdb) }

      let(:date){ Time.now.utc.to_date }
      let(:actual) do
        Sidekiq.redis do |conn|
          redis_hash = {}
          conn
            .hgetall(REDIS_HASH)
            .each do |keys, value|
              *keys, last = keys.split(":")
              keys.inject(redis_hash){ |hash, key| hash[key] || hash[key] = {} }[last.to_sym] = to_number(value)
            end

          redis_hash.values.last
        end

      end

      it 'records statistic for passed worker' do
        middlewared {}

        assert_equal 1, actual['HistoryWorker'][:passed]
        assert_equal 0, actual['HistoryWorker'][:failed]
      end

      it 'records statistic for failed worker' do
        begin
          middlewared do
            raise StandardError.new('failed')
          end
        rescue
        end

        assert_equal 0, actual['HistoryWorker'][:passed]
        assert_equal 1, actual['HistoryWorker'][:failed]
      end

      it 'records statistic for any workers' do
        middlewared { sleep 0.001 }
        begin
          middlewared do
            sleep 0.1
            raise StandardError.new('failed')
          end
        rescue
        end
        middlewared { sleep 0.001 }

        assert_equal 2, actual['HistoryWorker'][:passed]
        assert_equal 1, actual['HistoryWorker'][:failed]
      end

      it 'support multithreaded calculations' do
        workers = []
        25.times do
          workers << Thread.new do
            25.times { middlewared {} }
          end
        end

        workers.each(&:join)

        assert_equal 625, actual['HistoryWorker'][:passed]
      end

      it 'support ActiveJob workers' do
        message = {
          'class'   => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
          'wrapped' => 'RealWorkerClassName'
        }

        middlewared(ActiveJobWrapper, message) {}

        assert_equal actual.keys, ['RealWorkerClassName']
        assert_equal 1, actual['RealWorkerClassName'][:passed]
        assert_equal 0, actual['RealWorkerClassName'][:failed]
      end

      it 'records statistic for more than one worker' do
        middlewared{}
        middlewared(OtherHistoryWorker){}

        assert_equal 1, actual['HistoryWorker'][:passed]
        assert_equal 0, actual['HistoryWorker'][:failed]
        assert_equal 1, actual['OtherHistoryWorker'][:passed]
        assert_equal 0, actual['OtherHistoryWorker'][:failed]
      end
    end
  end
end
