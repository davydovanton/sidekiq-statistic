require 'minitest_helper'

module Sidekiq
  module History
    describe "Middleware" do
      before do
        Celluloid.boot
        $invokes = 0
        @boss = MiniTest::Mock.new
        @processor = ::Sidekiq::Processor.new(@boss)
        Sidekiq.server_middleware {|chain| chain.add Sidekiq::Failures::Middleware }
        Sidekiq.redis = REDIS
        Sidekiq.redis { |c| c.flushdb }
        Sidekiq.instance_eval { @failures_default_mode = nil }
      end

      TestException = Class.new(Exception)
    end
  end
end
