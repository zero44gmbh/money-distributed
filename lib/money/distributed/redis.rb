# typed: strict
# frozen_string_literal: true

class Money
  module Distributed
    # Wrapper over different parameters that can be provided for redis
    class Redis
      extend T::Sig

      sig do
        params(
          redis: T.any(::Redis, ConnectionPool, T::Hash[T.untyped, T.untyped], Proc),
        ).void
      end
      def initialize(redis)
        @redis_proc = T.let(build_redis_proc(redis), Proc)
      end

      sig do
        params(
          block: T.proc.params(redis_or_similar: T.untyped).returns(T.untyped),
        ).returns(T.untyped)
      end
      def exec(&block)
        @redis_proc.call(&block)
      end

      sig do
        params(
          redis: T.any(::Redis, ConnectionPool, T::Hash[T.untyped, T.untyped], Proc),
        ).returns(Proc)
      end
      private def build_redis_proc(redis)
        case redis
        when ::Redis
          proc { |&b| b.call(redis) }
        when ConnectionPool
          proc { |&b| redis.with { b.call(_1) } }
        when Hash
          build_redis_proc(::Redis.new(redis))
        when Proc
          redis
        else
          T.absurd(redis)
        end
      end
    end
  end
end
