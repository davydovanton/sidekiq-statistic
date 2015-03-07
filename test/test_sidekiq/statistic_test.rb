require 'minitest_helper'

module Sidekiq
  module History
    describe 'Statistic' do
      before do
        Sidekiq.redis { |c| c.flushdb }
      end

      it 'returns hash for each day' do
        history = Sidekiq::History::Statistic.new(30).workers_hash
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

        history = Sidekiq::History::Statistic.new(0).workers_hash
        worker_hash = history.first[Time.now.utc.to_date.to_s]

        assert_equal 1, worker_hash['HistoryWorker'][:failed]
        assert_equal 1, worker_hash['HistoryWorker'][:passed]
      end
    end
  end
end
