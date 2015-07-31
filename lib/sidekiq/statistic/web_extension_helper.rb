require 'json'

module Sidekiq
  module Statistic
    module WebExtensionHelper
      DAFAULT_DAYS = 20

      def formate_date(string, format = nil)
        time = string ? Time.parse(string) : Time.now
        time.strftime(format || '%T, %e %B %Y')
      end

      def calculate_date_range(params)
        if params['dateFrom'] && params['dateTo']
          from = Date.parse(params['dateFrom'])
          to   = Date.parse(params['dateTo'])

          [(to - from).to_i, to]
        else
          [DAFAULT_DAYS]
        end
      end
    end
  end
end
