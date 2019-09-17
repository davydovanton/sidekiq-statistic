# frozen_string_literal: true

# encoding: utf-8

require 'minitest_helper'

module Sidekiq
  class Helper < Sidekiq::WebAction
    include Sidekiq::Statistic::WebExtensionHelper
  end

  describe 'WebExtensionHelper' do
    include Rack::Test::Methods

    describe '.format_date' do
      let(:header) { { 'HTTP_ACCEPT_LANGUAGE' => 'pt-br' } }
      let(:datetime) { Time.now }
      let(:helper) { Helper.new(header, {}) }

      describe "when doesn't have translation" do
        before { header['HTTP_ACCEPT_LANGUAGE'] = 'xx-xx' }

        it 'return date with en format' do
          assert_equal helper.format_date(datetime), datetime.strftime('%m/%d/%Y')
        end
      end

      describe 'when have translation' do
        it 'return date with default format' do
          default_format = helper.get_locale.dig('date', 'formats', 'default')
          assert_equal helper.format_date(datetime), datetime.strftime(default_format)
        end

        it 'return date with datetime format' do
          datetime_format = helper.get_locale.dig('date', 'formats', 'datetime')
          assert_equal helper.format_date(datetime, 'datetime'), datetime.strftime(datetime_format)
        end
      end

      describe '#date_format' do
        describe 'when does not pass format' do
          it 'return the default format' do
            assert_equal helper.date_format, helper.get_locale.dig('date', 'formats', 'default')
          end
        end

        describe 'when pass format' do
          it 'return the format' do
            assert_equal helper.get_locale.dig('date', 'formats', 'datetime'), helper.date_format('datetime')
          end
        end
      end
    end

    describe '.calculate_date_range' do
      let(:helper) { Helper.new({}, {}) }

      it 'return the range between dates' do
        diference = 2
        today = Date.new
        two_days_ago = today - diference
        params = { 'dateFrom' => two_days_ago.to_s,
                   'dateTo' => today.to_s }

        helper.calculate_date_range(params).must_equal([diference, today])
      end

      it 'return default range' do
        helper.calculate_date_range({}).must_equal([20])
      end
    end
  end
end
