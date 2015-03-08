require 'minitest_helper'

module Sidekiq
  module History
    describe 'WorkerStatistic' do
      before do
        Sidekiq.redis { |c| c.flushdb }
      end

      it 'returns hash for each day' do
        history = Sidekiq::History::WorkerStatistic.new(30).redis_hash
        assert_equal 31, history.size
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
