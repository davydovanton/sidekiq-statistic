require 'minitest_helper'

module Sidekiq
  module History
    describe 'SortedEntry' do
      before do
        Sidekiq.redis { |c| c.flushdb }
      end

      it 'returns hash with all workers' do
        begin
          middlewared do
            raise StandardError.new('failed')
          end
        rescue
        end
        middlewared {}

        history = Sidekiq::History::SortedEntry.new.history
        assert_equal 2, history.size
        assert_equal 'success', history.first[:status]
      end
    end
  end
end
