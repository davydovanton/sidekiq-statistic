require 'minitest_helper'

module Sidekiq
  module History
    describe 'Middleware' do
      before do
        Sidekiq.redis { |c| c.flushdb }
      end

      let(:history) { "sidekiq:history:#{Time.now.utc.to_date}" }

      it 'records history json for passed worker' do
        middlewared {}

        entry = Sidekiq.redis do |redis|
          redis.hgetall(history)
        end
        actual = Sidekiq.load_json(entry['HistoryWorker']).symbolize_keys

        assert_equal 1, actual[:passed]
        assert_equal 0, actual[:failed]
      end

      it 'records history json for passed worker' do
        begin
          middlewared do
            raise StandardError.new('failed')
          end
        rescue
        end

        entry = Sidekiq.redis do |redis|
          redis.hgetall(history)
        end
        actual = Sidekiq.load_json(entry['HistoryWorker']).symbolize_keys

        assert_equal 0, actual[:passed]
        assert_equal 1, actual[:failed]
      end

      it 'records history for any workers' do
        middlewared { sleep 0.001 }
        begin
          middlewared do
            sleep 0.1
            raise StandardError.new('failed')
          end
        rescue
        end
        middlewared { sleep 0.001 }

        entry  = Sidekiq.redis { |redis| redis.hgetall(history) }
        actual = Sidekiq.load_json(entry['HistoryWorker']).symbolize_keys

        assert_equal 2, actual[:passed]
        assert_equal 1, actual[:failed]
        assert_equal 3, actual[:runtime].count
      end

      it 'support multithreaded calculations' do
        workers = []
        10.times do
          workers << Thread.new do
            100.times { middlewared {} }
          end
        end

        workers.each { |w| w.join }

        entry  = Sidekiq.redis { |redis| redis.hgetall(history) }
        actual = Sidekiq.load_json(entry['HistoryWorker']).symbolize_keys

        assert_equal 1000, actual[:passed]
      end
    end
  end
end
