# frozen_string_literal: true

require 'minitest_helper'

module Sidekiq
  module Statistic
    module Helpers
      describe Color do
        include Rack::Test::Methods

        let(:worker_name) { 'HistoryWorker' }
        let(:rgb_color) { '102,63,243' }
        let(:hex_color) { '#663FF3' }

        describe 'when passes rgb format' do
          describe '.for' do
            it 'returns rgb format' do
              assert_equal rgb_color, Color.for(worker_name, :rgb)
            end
          end
        end

        describe 'when passes hex format' do
          describe '.for' do
            it 'return hex format' do
              assert_equal hex_color, Color.for(worker_name, :hex)
            end
          end
        end
      end
    end
  end
end
