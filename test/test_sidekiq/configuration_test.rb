# frozen_string_literal: true

require 'minitest_helper'

module Sidekiq
  module Statistic
    describe 'Configuration' do
      describe '#max_timelist_length=' do
        it 'assigns correct value' do
          config = Configuration.new
          config.max_timelist_length = 12345
          assert_equal 12345, config.max_timelist_length
        end
      end
    end
  end
end
