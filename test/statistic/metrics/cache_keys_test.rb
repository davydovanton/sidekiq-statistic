# frozen_string_literal: true

require 'minitest_helper'

describe Sidekiq::Statistic::Metrics::CacheKeys do
  describe '#status' do
    describe 'for success status' do
      let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

      it 'returns correct key for "status" attribute' do
        travel_to Time.new(2021, 1, 17, 14, 00, 00) do
          result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

          assert_equal '2021-01-17:HistoryWorker:passed', result.status
        end
      end
    end

    describe 'for failure status' do
      let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

      it 'returns correct key for "status" attribute' do
        travel_to Time.new(2021, 1, 17, 14, 00, 00) do
          metric.fails!
          result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

          assert_equal '2021-01-17:HistoryWorker:failed', result.status
        end
      end
    end
  end

  describe '#class_name' do
    let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

    it 'returns correct key for "class_name" attribute' do
      result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

      assert_equal 'passed:HistoryWorker', result.class_name
    end
  end

  describe '#last_job_status' do
    let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

    it 'returns correct key for "last_job_status" attribute' do
      travel_to Time.new(2021, 1, 17, 14, 00, 00) do
        result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

        assert_equal '2021-01-17:HistoryWorker:last_job_status', result.last_job_status
      end
    end
  end

  describe '#last_time' do
    let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

    it 'returns correct key for "last_time" attribute' do
      travel_to Time.new(2021, 1, 17, 14, 00, 00) do
        result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

        assert_equal '2021-01-17:HistoryWorker:last_time', result.last_time
      end
    end
  end

  describe '#queue' do
    let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

    it 'returns correct key for "queue" attribute' do
      travel_to Time.new(2021, 1, 17, 14, 00, 00) do
        result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

        assert_equal '2021-01-17:HistoryWorker:queue', result.queue
      end
    end
  end

  describe '#timeslist' do
    let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

    it 'returns correct key for "timeslist" attribute' do
      travel_to Time.new(2021, 1, 17, 14, 00, 00) do
        result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

        assert_equal '2021-01-17:HistoryWorker:timeslist', result.timeslist
      end
    end
  end

  describe '#realtime' do
    let(:metric) { Sidekiq::Statistic::Metric.new('HistoryWorker') }

    it 'returns correct key for "realtime" attribute' do
      travel_to Time.new(2021, 1, 17, 14, 00, 00) do
        result = Sidekiq::Statistic::Metrics::CacheKeys.new(metric)

        assert_equal 'sidekiq:statistic:realtime:0', result.realtime
      end
    end
  end
end
