# frozen_string_literal: true

module Sidekiq
  module Statistic
    class Metric
      JOB_MAILER_ID = 'ActionMailer::DeliveryJob'
      STATUSES = {
        success: :passed,
        failure: :failed
      }.freeze

      def self.for(class_name:, arguments: [])
        if class_name == JOB_MAILER_ID
          clazz_from_mailer = arguments
            .first['arguments']
            .first

          new(clazz_from_mailer)
        else
          new(class_name)
        end
      end

      attr_accessor :queue, :status
      attr_reader :class_name, :finished_at

      def initialize(class_name)
        @class_name = class_name
        @status = STATUSES[:success]
        @queue = 'default'

        Time.now.utc.tap do |t|
          @started_at = t
          @finished_at = t
        end
      end

      def fails!
        @status = STATUSES[:failure]
      end

      def start
        @started_at = Time.now.utc
      end

      def finish
        @finished_at = Time.now.utc
      end

      def duration
        (@finished_at - @started_at).to_f.round(3)
      end
    end
  end
end
