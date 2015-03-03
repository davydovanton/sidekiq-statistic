require 'minitest_helper'

module Sidekiq
  module History
    describe 'SortedEntry' do
      before do
        Sidekiq.redis { |c| c.flushdb }
      end

      it 'returns hash with all workers' do
        middlewared {}

        begin
          middlewared do
            raise StandardError.new('failed')
          end
        rescue
        end

        sorted_entry = Sidekiq::History::SortedEntry.new.history
        assert_equal 2, sorted_entry[:history].size
      end
    end
  end
end
