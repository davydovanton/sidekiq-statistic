# frozen_string_literal: true

module Sidekiq
  module Statistic
    module Helpers
      class Color
        def self.color_for(worker)
          Digest::MD5.hexdigest(worker)[0..5]
            .scan(/../)
            .map{ |color| color.to_i(16) }
            .join ','
        end

        def self.rgb_to_hex(rgb)
          '#' + rgb.split(',').map { |v| v.to_i.to_s(16).rjust(2, '0').upcase }.join
        end
      end
    end
  end
end
