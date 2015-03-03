require 'minitest_helper'

module Sidekiq
  module History
    describe 'Middleware' do
      it 'records history for passed workers' do
        middlewared {}

        entry = Sidekiq.redis do |redis|
          redis.lrange('sidekiq:history', 0, -1)
        end

        actual = Sidekiq.load_json(entry[0]).symbolize_keys

        assert_equal 'success', actual[:status]
        assert_equal 'HistoryWorker', actual[:name]

        assert_empty actual[:error]
        assert_empty actual[:backtrace]
        assert_empty actual[:exception]
      end

      it 'records history for failed workers' do
        begin
          middlewared do
            raise StandardError.new('failed')
          end
        rescue
        end

        entry = Sidekiq.redis do |redis|
          redis.lrange('sidekiq:history', 0, -1)
        end

        actual = Sidekiq.load_json(entry[0]).symbolize_keys

        assert_equal 'failure', actual[:status]
        assert_equal 'HistoryWorker', actual[:name]

        assert_equal 'StandardError', actual[:exception]
        assert_equal 'failed', actual[:error]
      end
    end
  end
end
