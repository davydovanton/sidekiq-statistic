# frozen_string_literal: true

module Sidekiq
  module Statistic
    module Helpers
      module Color
        class << self
          BASE = 16
          LIMIT_NUMBERT_TO_AVOID_WHITES = 215

          def for(phrase, format: :rgb)
            return hex(phrase) if format == :hex

            rgb(phrase)
          end

          private

          def rgb(phrase)
            digested_unique_color(phrase).join(',')
          end

          def hex(phrase)
            '#' + digested_unique_color(phrase).map do |number|
              number.to_s(BASE).rjust(2, '0')
            end.join
          end

          def digested_unique_color(phrase)
            Digest::MD5.hexdigest(phrase)[0..5]
                       .scan(/../)
                       .map(&method(:hex_pair_to_number))
          end

          def hex_pair_to_number(pair)
            pair.to_i(BASE) % LIMIT_NUMBERT_TO_AVOID_WHITES
          end
        end
      end
    end
  end
end
