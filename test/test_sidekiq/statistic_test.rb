# frozen_string_literal: true

require 'minitest_helper'

module Sidekiq
  module Statistic
    describe 'Workers' do
      before { Sidekiq.redis(&:flushdb) }

      let(:statistic) { Sidekiq::Statistic::Workers.new(1) }
      let(:base_statistic) { Sidekiq::Statistic::Base.new(1) }
      let(:worker) { 'HistoryWorker' }

      describe '#number_of_calls' do
        it 'returns success jobs count for worker' do
          10.times { middlewared {} }

          count = statistic.number_of_calls('HistoryWorker')
          assert_equal 10, count[:success]
        end

        describe 'when success jobs were not call' do
          it 'returns zero' do
            10.times do
              begin
                middlewared do
                  raise StandardError.new('failed')
                end
              rescue
              end
            end

            count = statistic.number_of_calls('HistoryWorker')
            assert_equal 0, count[:success]
          end
        end

        it 'returns failure jobs count for worker' do
          10.times do
            begin
              middlewared do
                raise StandardError.new('failed')
              end
            rescue
            end
          end

          count = statistic.number_of_calls('HistoryWorker')
          assert_equal 10, count[:failure]
        end

        describe 'when failure jobs were not call' do
          it 'returns zero' do
            10.times { middlewared {} }

            count = statistic.number_of_calls('HistoryWorker')
            assert_equal 0, count[:failure]
          end
        end

        it 'returns total jobs count for worker' do
          10.times do
            middlewared {}

            begin
              middlewared do
                raise StandardError.new('failed')
              end
            rescue
            end
          end

          count = statistic.number_of_calls('HistoryWorker')

          assert_equal 20, count[:total]
        end

        describe 'when total jobs were not call' do
          it 'returns zero' do
            count = statistic.number_of_calls('HistoryWorker')
            assert_equal 0, count[:failure]
          end
        end

        it 'returns proper stats for nested workers' do
          middlewared(Nested::HistoryWorker) {}

          count = statistic.number_of_calls('Nested::HistoryWorker')
          assert_equal 1, count[:total]
        end
      end

      describe '#display' do
        it 'return workers' do
          middlewared {}

          subject = statistic.display

          _(subject).must_be_instance_of Array
          assert_equal subject[0].keys.sort,
                       %i[name last_job_status number_of_calls queue runtime].sort

          assert_equal worker, subject[0][:name]
        end
      end

      describe '#display_by_last_status' do
        it 'return workers separated by their last status' do
          middlewared {}

          subject = statistic.display_by_last_status

          _(subject).must_be_instance_of Hash
          assert_equal subject.keys.sort,
                       %i[passed failed].sort

          _(subject[:passed]).must_be_instance_of Array
          _(subject[:failed]).must_be_instance_of Array
          assert_equal subject[:passed][0].keys.sort,
                      %i[name last_job_status number_of_calls queue runtime].sort

          assert_equal worker, subject[:passed][0][:name]
        end
      end

      describe "#filter_last_job_status" do
        it 'return array with worker when filtering by passed workers' do
          middlewared {}

          subject = statistic.filter_last_job_status('passed')

          _(subject).must_be_instance_of Array
          assert_equal subject[0][:name], worker
        end
      end

      describe '#display_per_day' do
        it 'return workers job per day' do
          middlewared {}

          subject = statistic.display_per_day(worker)

          _(subject).must_be_instance_of Array
          assert_equal subject[0].keys.sort,
                       %i[date failure last_job_status runtime success total].sort
          assert_equal Time.now.strftime("%Y-%m-%d"), subject[0][:date]
        end
      end

      describe '#runtime_for_day' do
        it 'return runtime' do
          middlewared {}

          worker_statistic = base_statistic.statistic_for(worker)[1]
          subject = statistic.runtime_for_day(worker, worker_statistic)

          _(subject).must_be_instance_of Hash
          assert_equal subject.keys.sort, %i[average last max min total].sort
          assert_equal worker_statistic[:average_time], subject[:average]
          assert_equal worker_statistic[:last_time], subject[:last]
          assert_equal worker_statistic[:max_time], subject[:max]
          assert_equal worker_statistic[:min_time], subject[:min]
          assert_equal worker_statistic[:total_time], subject[:total]
        end
      end

      describe '#number_of_calls_for' do
        it 'count passed jobs' do
          5.times { middlewared {} }

          count = statistic.number_of_calls_for(:passed, worker)

          assert_equal 5, count
        end

        it 'count failed jobs' do
          5.times do
            middlewared {}

            begin
              middlewared do
                raise StandardError.new('failed')
              end
            rescue
            end
          end

          count = statistic.number_of_calls_for(:failed, worker)

          assert_equal 5, count
        end
      end

      describe '#last_job_status_for' do
        it 'failed last job' do
          middlewared {}
          middlewared {}
          begin
            middlewared do
              raise StandardError.new('failed')
            end
          rescue
          end

          status = statistic.last_job_status_for(worker)

          assert_equal 'failed', status
        end

        it 'passed last job' do
          middlewared {}
          begin
            middlewared do
              raise StandardError.new('failed')
            end
          rescue
          end
          middlewared {}

          status = statistic.last_job_status_for(worker)

          assert_equal 'passed', status
        end
      end

      describe '#last_queue' do
        it 'returns last queue' do
          message = { 'queue' => 'queue_test' }
          middlewared(HistoryWorker, message) {}

          last_queue = statistic.last_queue(worker)
          assert_equal message['queue'], last_queue
        end
      end

      describe '#runtime_statistic' do
        it 'returns instance of Runtime' do
          middlewared {}

          runtime_statistic = statistic.runtime_statistic(worker)
          assert_instance_of Sidekiq::Statistic::Runtime, runtime_statistic
        end

        it 'returns object with value passed' do
          middlewared {}

          time = 1.00268
          runtime_statistic = statistic.runtime_statistic(worker, { average_time: time })

          assert_equal runtime_statistic.average_runtime, time
        end
      end
    end
  end
end
