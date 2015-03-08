module Sidekiq
  module History
    module WebExtension
      def self.registered(app)
        view_path = File.join(File.expand_path('..', __FILE__), 'views')

        app.helpers do
        end

        app.get '/history' do
          @worker_statistic = Sidekiq::History::WorkerStatistic.new(20)
          @tooltip_template = '<%= datasetLabel %> - <%= value %>'
          render(:erb, File.read(File.join(view_path, 'history.erb')))
        end
      end
    end
  end
end
