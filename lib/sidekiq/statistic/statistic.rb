module Sidekiq
  module Statistic
    class Statistic
      def initialize(days_previous, start_date = nil)
        @start_date = start_date || Time.now.utc.to_date
        @end_date = @start_date - days_previous
      end

      def for_worker(worker)
        hash.map{ |h| h.values.first[worker] || {} }
      end

      def worker_names
        @worker_names ||= hash.flat_map{ |h| h.values.first.keys }.uniq
      end

      def hash
        @redis_hash = Sidekiq.redis do |conn|
          redis_hash = {}
          conn
            .hgetall(REDIS_HASH)
            .each do |keys, value|
              *keys, last = keys.split(':'.freeze)
              keys.inject(redis_hash, &key_or_empty_hash)[last.to_sym] = to_number(value)
            end

          desired_dates.map { |key| result_hash(redis_hash, key) }
        end
      end

    private

      def key_or_empty_hash
        ->(h, k) { h[k] || h[k] = {} }
      end

      def desired_dates
        (@end_date..@start_date).map(&:to_s)
      end

      def result_hash(redis_hash, key)
        redis_hash.fetch(key, {}).each { |_, v| update_hash_statments v }
        { key => (redis_hash[key] || {}) }
      end

      def update_hash_statments(hash)
        hash[:passed] ||= 0
        hash[:failed] ||= 0
      end

      def to_number(value)
        case value
        when /\A[\d.]+\z/ then value.to_f
        when /\A\d+\z/ then value.to_i
        else value
        end
      end
    end
  end
end
