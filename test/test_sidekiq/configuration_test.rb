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

        it 'raises error if value is not a number' do
          config = Configuration.new
          assert_raises(ArgumentError) { config.max_timelist_length = nil }
        end

        it 'raises error if value is less than 1' do
          config = Configuration.new
          assert_raises(ArgumentError) { config.max_timelist_length = 0 }
        end
      end
    end
  end
end
