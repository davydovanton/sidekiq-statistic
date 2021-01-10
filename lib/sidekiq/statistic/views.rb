# frozen_string_literal: true

module Sidekiq
  module Statistic
    module Views
      PATH = File.join(File.expand_path('..', __FILE__), 'views')

      def self.require_assets(name)
        path = File.join(PATH, name)

        [File.read(path)]
      end
    end
  end
end
