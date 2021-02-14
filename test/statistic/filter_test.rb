# frozen_string_literal: true

require 'minitest_helper'

describe Sidekiq::Statistic::Filter do
	describe '.past_thirty_days' do
		it 'assigns correct "from" and "to" dates' do
			travel_to Time.new(2021, 1, 31, 14, 00, 00) do
	      result = Sidekiq::Statistic::Filter.past_thirty_days

	      # Reading instance variables directly only for test purpose
	      assert_equal result.instance_variable_get(:@from).to_s, '2021-01-01'
	      assert_equal result.instance_variable_get(:@to).to_s, '2021-01-31'
	    end
    end
	end

	describe '.yesterday' do
		it 'assigns correct "from" and "to" dates' do
			travel_to Time.new(2021, 1, 31, 14, 00, 00) do
	      result = Sidekiq::Statistic::Filter.yesterday

	      # Reading instance variables directly only for test purpose
	      assert_equal result.instance_variable_get(:@from).to_s, '2021-01-30'
	      assert_equal result.instance_variable_get(:@to).to_s, '2021-01-31'
	    end
    end
	end

	describe '#range' do
		it 'assigns correct "from" and "to" dates' do
			travel_to Time.new(2021, 1, 31, 14, 00, 00) do
	      result = Sidekiq::Statistic::Filter.yesterday.range

	      assert_equal result, %w[2021-01-30 2021-01-31]
	    end
    end
	end
end
