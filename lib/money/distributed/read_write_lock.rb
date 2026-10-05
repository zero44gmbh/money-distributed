# typed: strict
# frozen_string_literal: true

class Money
  module Distributed
    class ReadWriteLock
      extend T::Sig

      sig do
        params(
          lock: Concurrent::ReentrantReadWriteLock,
          _: T.proc.returns(T.untyped),
        ).returns(T.untyped)
      end
      def self.read(lock, &_)
        lock.acquire_read_lock
        begin
          yield
        ensure
          lock.release_read_lock
          nil
        end
      end

      sig do
        params(
          lock: Concurrent::ReentrantReadWriteLock,
          _: T.proc.void,
        ).void
      end
      def self.write(lock, &_)
        lock.acquire_write_lock
        begin
          yield
        ensure
          lock.release_write_lock
        end
      end
    end
  end
end
