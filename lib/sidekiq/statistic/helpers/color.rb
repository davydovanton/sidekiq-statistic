# frozen_string_literal: true

module Sidekiq
  module Statistic
    module Helpers
      class Color
        class << self
          def for(worker_name, format = :rgb)
            rgb = Digest::MD5.hexdigest(worker_name)[0..5]
                             .scan(/../)
                             .map { |color| color.to_i(16) }
                             .join(',')

            return to_hex(rgb) if format == :hex

            rgb
          end

          private

          def to_hex(rgb)
            '#' + rgb.split(',').map { |v| v.to_i.to_s(16).rjust(2, '0').upcase }.join
          end
        end
      end
    end
  end
end
