require 'minitest_helper'

module Sidekiq
  module History
    describe 'Charts' do
      before do
        Sidekiq.redis(&:flushdb)
      end

      let(:worker_static) { Sidekiq::History::Charts.new(1) }

      describe '#dates' do
        it 'returns array with all days' do
          days = worker_static.dates
          assert_equal Time.now.utc.to_date.to_s, days.last
        end
      end
    end
  end
end
