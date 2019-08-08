# frozen_string_literal: true

# encoding: utf-8

require 'minitest_helper'
require 'json'

module Sidekiq
  class Helper < Sidekiq::WebAction
    include Sidekiq::Statistic::WebExtensionHelper
  end

  describe 'WebExtensionHelper' do
    include Rack::Test::Methods

    describe '.format_date' do
      let(:header) { { 'HTTP_ACCEPT_LANGUAGE' => 'pt-br' } }
      let(:datetime) { Time.now }

      describe "when doesn't have translation" do
        it 'return date with en format' do
          header['HTTP_ACCEPT_LANGUAGE'] = 'xx-xx'

          helper = Helper.new(header, {})

          assert_equal helper.format_date(datetime), datetime.strftime('%m/%d/%Y')
        end
      end

      describe 'when have translation' do
        let(:helper) { Helper.new(header, {}) }
        it 'return date with default format' do
          default_format = helper.get_locale.dig('date', 'formats', 'default')
          assert_equal helper.format_date(datetime), datetime.strftime(default_format)
        end

        it 'return date with datetime format' do
          datetime_format = helper.get_locale.dig('date', 'formats', 'datetime')
          assert_equal helper.format_date(datetime, 'datetime'), datetime.strftime(datetime_format)
        end
      end
    end
  end
end
