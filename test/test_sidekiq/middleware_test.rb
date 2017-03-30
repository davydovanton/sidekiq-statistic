require 'minitest_helper'
require 'mocha/setup'

module Sidekiq
  module Statistic
    describe 'Middleware' do
      def to_number(i)
        i.match('\.').nil? ? Integer(i) : Float(i) rescue i.to_s
      end

      before { Sidekiq.redis(&:flushdb) }

      let(:date){ Time.now.utc.to_date }
      let(:actual) do
        Sidekiq.redis do |conn|
          redis_hash = {}
          conn
            .hgetall(REDIS_HASH)
            .each do |keys, value|
              *keys, last = keys.split(":")
              keys.inject(redis_hash){ |hash, key| hash[key] || hash[key] = {} }[last.to_sym] = to_number(value)
            end

          redis_hash.values.last
        end

      end

      it 'records statistic for passed worker' do
        middlewared {}

        assert_equal 1, actual['HistoryWorker'][:passed]
        assert_equal nil, actual['HistoryWorker'][:failed]
      end

      it 'records statistic for failed worker' do
        begin
          middlewared do
            raise StandardError.new('failed')
          end
        rescue
        end

        assert_equal nil, actual['HistoryWorker'][:passed]
        assert_equal 1, actual['HistoryWorker'][:failed]
      end

      it 'records statistic for any workers' do
        middlewared { sleep 0.001 }
        begin
          middlewared do
            sleep 0.1
            raise StandardError.new('failed')
          end
        rescue
        end
        middlewared { sleep 0.001 }

        assert_equal 2, actual['HistoryWorker'][:passed]
        assert_equal 1, actual['HistoryWorker'][:failed]
      end

      it 'support multithreaded calculations' do
        workers = []
        20.times do
          workers << Thread.new do
            25.times { middlewared {} }
          end
        end

        workers.each(&:join)

        assert_equal 500, actual['HistoryWorker'][:passed]
      end

      it 'removes 1/4 the timelist entries after crossing max_timelist_length' do
        workers = []
        Sidekiq::Statistic.configuration.max_timelist_length = 10
        11.times do
          middlewared {}
        end

        assert_equal 8, Sidekiq.redis { |conn| conn.llen("#{Time.now.strftime "%Y-%m-%d"}:HistoryWorker:timeslist") }
      end

      it 'supports ActiveJob workers' do
        message = {
          'class'   => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
          'wrapped' => 'RealWorkerClassName'
        }

        middlewared(ActiveJobWrapper, message) {}

        assert_equal actual.keys, ['RealWorkerClassName']
        assert_equal 1, actual['RealWorkerClassName'][:passed]
        assert_equal nil, actual['RealWorkerClassName'][:failed]
      end

      it 'supports mailers called from AJ' do
        message = {
          'class'   => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
          'wrapped' => 'ActionMailer::DeliveryJob',
          'args'    => [{
            'job_class' => 'ActionMailer::DeliveryJob',
            'job_id'=>'cdcc67fb-8fdc-490c-9226-9c7f46a2dbaf',
            'queue_name'=>'mailers',
            'arguments' => ['WrappedMailer', 'welcome_email', 'deliver_now']
          }]
        }

        middlewared(ActiveJobWrapper, message) {}

        assert_equal actual.keys, ['WrappedMailer']
        assert_equal 1, actual['WrappedMailer'][:passed]
        assert_equal nil, actual['WrappedMailer'][:failed]
      end

      it 'records statistic for more than one worker' do
        middlewared{}
        middlewared(OtherHistoryWorker){}

        assert_equal 1, actual['HistoryWorker'][:passed]
        assert_equal nil, actual['HistoryWorker'][:failed]
        assert_equal 1, actual['OtherHistoryWorker'][:passed]
        assert_equal nil, actual['OtherHistoryWorker'][:failed]
      end

      it 'records queue statistic for each worker' do
        message = { 'queue' => 'default' }
        middlewared(HistoryWorker, message){}
        message = { 'queue' => 'test' }
        middlewared(HistoryWorkerWithQueue, message){}

        assert_equal 'default', actual['HistoryWorker'][:queue]
        assert_equal 'test', actual['HistoryWorkerWithQueue'][:queue]
      end
    end
  end
end
