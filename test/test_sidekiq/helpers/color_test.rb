# frozen_string_literal: true

require 'minitest_helper'

module Sidekiq
  module Statistic
    module Helpers
      describe Color do
        include Rack::Test::Methods

        let(:phrase) { 'HistoryWorker' }

        describe 'when passes rgb format' do
          describe '.for' do
            it 'returns rgb format' do
              assert_equal '102,63,28', Color.for(phrase, format: :rgb)
            end
          end
        end

        describe 'when passes hex format' do
          describe '.for' do
            it 'return hex format' do
              assert_equal '#663f1c', Color.for(phrase, format: :hex)
            end
          end
        end
      end
    end
  end
end
