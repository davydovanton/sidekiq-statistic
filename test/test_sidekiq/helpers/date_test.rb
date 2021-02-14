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

    describe '.build_filter_from_request' do
      let(:clazz) { Helper.new({}, {}) }

      it 'returns Filter instance with correct data' do
        helper_date.stub :params, { 'dateFrom' => '2021-02-13T10:15:00', 'dateTo' => '2021-02-14T10:15:00' } do
          assert_equal helper_date.build_filter_from_request.range, %w[2021-02-13 2021-02-14]
        end
      end
    end
  end
end
