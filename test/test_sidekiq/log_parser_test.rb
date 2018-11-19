# frozen_string_literal: true

require 'minitest_helper'

module Sidekiq
  module Statistic
    describe 'LogParser' do
      let(:log_parser) { Sidekiq::Statistic::LogParser.new('HistoryWorker') }

      before do
        Sidekiq::Statistic.configure do |config|
          config.log_file = 'test/helpers/logfile.log'
          config.last_log_lines = 1_000
        end
      end

      describe '#parse' do
        describe 'when worker called' do
          it 'returns array with lines' do
            result = ["HistoryWorker (done) <span class=\"statistic__jid js-jid__36a2b8bd6a370834f979f5ee\"data-target=\".js-jid__36a2b8bd6a370834f979f5ee\" style=\"background-color: rgba(255,41,135,0.2);\">JID-36a2b8bd6a370834f979f5ee</span>",
                      "HistoryWorker (start)",
                      "HistoryWorker (fail) <span class=\"statistic__jid js-jid__219f4e9b9013bfec76faa270\"data-target=\".js-jid__219f4e9b9013bfec76faa270\" style=\"background-color: rgba(116,63,167,0.2);\">JID-219f4e9b9013bfec76faa270</span>"]

            assert_equal result, log_parser.parse
          end

          describe 'when last_log_lines option set to 1' do
            it 'returns array with one line' do
              Sidekiq::Statistic.configuration.last_log_lines = 1

              result = ["HistoryWorker (fail) <span class=\"statistic__jid js-jid__219f4e9b9013bfec76faa270\"data-target=\".js-jid__219f4e9b9013bfec76faa270\" style=\"background-color: rgba(116,63,167,0.2);\">JID-219f4e9b9013bfec76faa270</span>"]
              assert_equal  result, log_parser.parse
            end
          end
        end

        describe 'when worker don\'t called' do
          it 'returns empty array' do
            other_log_parse = Sidekiq::Statistic::LogParser.new('FailedHistoryWorker')
            assert_equal [], other_log_parse.parse
          end
        end
      end

      describe '#sub_line' do
        it 'returns substituted log line' do
          substituted_line = "HistoryWorker (done) <span class=\"statistic__jid js-jid__219f4e9b9013bfec76faa270\"data-target=\".js-jid__219f4e9b9013bfec76faa270\" style=\"background-color: rgba(116,63,167,0.2);\">JID-219f4e9b9013bfec76faa270</span>"
          assert_equal 'HistoryWorker (done)', log_parser.sub_line('HistoryWorker (done)')
          assert_equal substituted_line, log_parser.sub_line('HistoryWorker (done) JID-219f4e9b9013bfec76faa270')
        end
      end
    end
  end
end
