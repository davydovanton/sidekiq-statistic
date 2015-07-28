require 'minitest_helper'

module Sidekiq
  module Statistic
    describe 'LogParser' do
      let(:log_parser) { Sidekiq::Statistic::LogParser.new('HistoryWorker') }

      before do
        Sidekiq::Statistic.configure do |config|
          config.log_file = 'test/helpers/logfile.log'
        end
      end

      describe '#parse' do
        describe 'when worker called' do
          it 'returns array with line hashes' do
            result = [
              { color: 'green', text: 'HistoryWorker (done)' },
              { color: 'yellow', text: 'HistoryWorker (start)' },
              { color: 'red', text: 'HistoryWorker (fail)' }
            ]

            assert_equal result, log_parser.parse
          end
        end

        describe 'when worker don\'t called' do
          it 'returns empty array' do
            other_log_parse = Sidekiq::Statistic::LogParser.new('FailedHistoryWorker')
            assert_equal [], other_log_parse.parse
          end
        end
      end

      describe '#line_hash' do
        it 'returns hash with string color and text' do
          hash = { color: 'green', text: 'HistoryWorker (done)' }
          assert_equal hash, log_parser.line_hash('HistoryWorker (done)')
        end
      end

      describe '#color' do
        it 'returns green for string contain "done"' do
          assert_equal 'green', log_parser.color('HistoryWorker (done)')
        end

        it 'returns yellow for string contain "start"' do
          assert_equal 'yellow', log_parser.color('HistoryWorker (start)')
        end

        it 'returns red for string contain "fail"' do
          assert_equal 'red', log_parser.color('HistoryWorker (fail)')
        end

        it 'returns nothing for others case' do
          assert_equal nil, log_parser.color('HistoryWorker (unknow status)')
        end
      end
    end
  end
end
