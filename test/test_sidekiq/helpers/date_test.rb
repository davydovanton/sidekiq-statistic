# frozen_string_literal: true

require 'minitest_helper'

module Sidekiq
  class Helper < Sidekiq::WebAction
    include Sidekiq::Statistic::Helpers::Date
  end

  describe Statistic::Helpers::Date do
    include Rack::Test::Methods

    let(:header) { { 'HTTP_ACCEPT_LANGUAGE' => 'pt-br' } }
    let(:helper_date) { Helper.new(header, {}) }

    describe '.format_date' do
      let(:datetime) { Time.now }

      describe "when doesn't have translation" do
        before { header['HTTP_ACCEPT_LANGUAGE'] = 'xx-xx' }

        it 'returns date with en format' do
          expected = datetime.strftime('%m/%d/%Y')
          assert_equal helper_date.format_date(datetime), expected
        end
      end

      describe 'when have translation' do
        it 'returns date with default format' do
          default_format = helper_date.get_locale.dig('date', 'formats', 'default')
          expected = datetime.strftime(default_format)

          assert_equal helper_date.format_date(datetime), expected
        end

        it 'returns date with datetime format' do
          datetime_format = helper_date.get_locale.dig('date', 'formats', 'datetime')
          expected = datetime.strftime(datetime_format)

          assert_equal helper_date.format_date(datetime, 'datetime'), expected
        end
      end
    end

    describe '.calculate_date_range' do
      let(:helper_date) { Helper.new({}, {}) }

      it 'returns the range between dates' do
        diference = 2
        today = Date.new
        two_days_ago = today - diference
        params = { 'dateFrom' => two_days_ago.to_s,
                   'dateTo' => today.to_s }

        _(helper_date.calculate_date_range(params)).must_equal([diference, today])
      end

      it 'returns default range' do
        _(helper_date.calculate_date_range({})).must_equal([20])
      end
    end
  end
end
