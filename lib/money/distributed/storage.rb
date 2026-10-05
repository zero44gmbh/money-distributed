# typed: true
# frozen_string_literal: true

class Money
  module Distributed
    # Storage for `Money::Bank::VariableExchange` that stores rates in Redis
    class Storage
      extend T::Sig

      INDEX_KEY_SEPARATOR = '_TO_'
      REDIS_KEY = 'money_rates'

      sig do
        params(
          redis: T.any(::Redis, ConnectionPool, T::Hash[T.untyped, T.untyped], Proc),
          cache_ttl: T.nilable(Integer),
        ).void
      end
      def initialize(redis, cache_ttl = nil)
        @redis = T.let(Money::Distributed::Redis.new(redis), Money::Distributed::Redis)

        @cache = T.let({}, T::Hash[String, BigDecimal])
        @cache_ttl = cache_ttl
        @cache_updated_at = T.let(nil, T.nilable(Time))

        @lock = Concurrent::ReentrantReadWriteLock.new
      end

      sig do
        params(
          iso_from: String,
          iso_to: String,
          rate: T.nilable(Numeric),
        ).void
      end
      def add_rate(iso_from, iso_to, rate)
        # other gems, e.g. "money-open-exchange-rates", may return nil and use Float
        return if rate.nil?

        @redis.exec do |r|
          r.hset(REDIS_KEY, key_for(iso_from, iso_to), rate.to_s)
        end
        clear_cache
      end

      sig do
        params(
          iso_from: String,
          iso_to: String,
        ).returns(T.nilable(BigDecimal))
      end
      def get_rate(iso_from, iso_to)
        cached_rates[key_for(iso_from, iso_to)]
      end

      def each_rate(&block)
        enum = Enumerator.new do |yielder|
          cached_rates.each do |key, rate|
            iso_from, iso_to = key.split(INDEX_KEY_SEPARATOR)
            yielder.yield iso_from, iso_to, rate
          end
        end

        block ? enum.each(&block) : enum
      end

      def transaction
        # We don't need transactions, we all thread safe here
        yield
      end

      sig { returns(T::Array[T.untyped]) }
      def marshal_dump
        [self.class, @cache_ttl]
      end

      sig do
        params(
          iso_from: String,
          iso_to: String,
        ).returns(String)
      end
      private def key_for(iso_from, iso_to)
        [iso_from, iso_to].join(INDEX_KEY_SEPARATOR).upcase
      end

      def cached_rates
        Money::Distributed::ReadWriteLock.read(@lock) do
          retrieve_rates if @cache.empty? || cache_outdated?
          @cache
        end
      end

      sig { returns(T::Boolean) }
      private def cache_outdated?
        return false unless @cache_ttl

        @cache_updated_at.nil? ||
        @cache_updated_at < Time.now - @cache_ttl
      end

      sig { void }
      def clear_cache
        Money::Distributed::ReadWriteLock.write(@lock) do
          @cache.clear
        end
      end

      sig { void }
      private def retrieve_rates
        updated_cache = {}

        @redis.exec do |r|
          r.hgetall(REDIS_KEY).each_with_object(updated_cache) do |(key, val), h|
            next if val.nil? || val == ''

            h[key] = BigDecimal(val)
          end
        end

        @cache = updated_cache
        @cache_updated_at = Time.now
      end
    end
  end
end
