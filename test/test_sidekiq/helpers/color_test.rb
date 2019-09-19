# frozen_string_literal: true

# encoding: utf-8

require 'minitest_helper'
require 'json'

module Sidekiq
  module Statistic
    module Helpers
      describe 'Color' do
        include Rack::Test::Methods

        let(:worker) { 'HistoryWorker' }
        let(:rgb_color) { '102,63,243' }
        let(:hex_color) { '#663FF3' }

        describe '.color_for' do
          it 'return rgb color' do
            assert_equal Color.color_for(worker), rgb_color
          end
        end

        describe '.rgb_to_hex' do
          it 'convert rgb color to hexadecimal' do
            assert_equal hex_color, Color.rgb_to_hex(rgb_color)
          end
        end
      end
    end
  end
end
