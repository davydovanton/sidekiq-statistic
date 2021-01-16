# frozen_string_literal: true

require 'minitest_helper'

describe Sidekiq::Statistic::Views do
  before do
    @views = Sidekiq::Statistic::Views
  end

  describe '.require_assets' do
    it 'returns content if file exists' do
      content = @views.require_assets('styles/common.css').first

      _(content).must_match(/=== COMMON ===/)
    end

    it 'raises an error if file does not exist' do
      assert_raises Errno::ENOENT do 
        @views.require_assets('styles/abc.css')
      end
    end
  end
end
