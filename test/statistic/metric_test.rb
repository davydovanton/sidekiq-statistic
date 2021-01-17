# frozen_string_literal: true

require 'minitest_helper'

describe Sidekiq::Statistic::Metric do
  describe '.for' do
    describe 'when running "ActionMailer" jobs' do
      it 'extracts class name from "args"' do
        instance = Sidekiq::Statistic::Metric.for(
          class_name: 'ActionMailer::DeliveryJob',
          arguments: [
            { 'arguments' => ['MyWorkerClass'] }
          ]
        )

        assert_equal 'MyWorkerClass', instance.class_name
      end
    end

    describe 'when running common jobs' do
      it 'does not try to extract class name from "args"' do
        instance = Sidekiq::Statistic::Metric.for(
          class_name: 'MyWorkerClass'
        )

        assert_equal 'MyWorkerClass', instance.class_name
      end
    end
  end

  describe '#status' do
    it 'assigns "default" for "status" attribute' do
      instance = Sidekiq::Statistic::Metric.new('MyWorkerClass')

      assert_equal :passed, instance.status
    end
  end

  describe '#status=' do
    it 'assigns given value for "status" attribute' do
      instance = Sidekiq::Statistic::Metric.new('MyWorkerClass')

      assert_equal :passed, instance.status

      instance.status = Sidekiq::Statistic::Metric::STATUSES[:failure]

      assert_equal :failed, instance.status
    end
  end

  describe '#queue' do
    it 'assigns "default" for "queue" attribute' do
      instance = Sidekiq::Statistic::Metric.new('MyWorkerClass')

      assert_equal 'default', instance.queue
    end
  end

  describe '#queue=' do
    it 'assigns given value for "queue" attribute' do
      instance = Sidekiq::Statistic::Metric.new('MyWorkerClass')

      assert_equal 'default', instance.queue

      instance.queue = 'test'

      assert_equal 'test', instance.queue
    end
  end

  describe '#finished_at' do
    it 'assigns current time for "finished_at" attribute' do
      travel_to Time.new(2021, 1, 17, 14, 00, 00) do
        instance = Sidekiq::Statistic::Metric.new('MyWorkerClass')

        assert_equal Time.new(2021, 1, 17, 14, 00, 00), instance.finished_at
      end
    end
  end

  describe '#fails!' do
    it 'assigns failure for status' do
      instance = Sidekiq::Statistic::Metric.new('MyWorkerClass')

      assert_equal :passed, instance.status

      instance.fails!

      assert_equal :failed, instance.status      
    end
  end

  describe '#duration' do
    it 'returns the difference between start and finish' do
      instance = nil

      travel_to Time.new(2021, 1, 17, 14, 00, 00) do
        instance = Sidekiq::Statistic::Metric.new('MyWorkerClass')
      end

      travel_to Time.new(2021, 1, 17, 14, 10, 00) do
        instance.start
      end

      travel_to Time.new(2021, 1, 17, 14, 12, 00) do
        instance.finish
      end

      assert_equal 120, instance.duration
    end
  end
end
