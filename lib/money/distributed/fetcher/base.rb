# typed: strict
# frozen_string_literal: true

class Money
  module Distributed
    module Fetcher
      # Base class for rates fetchers
      module Base
        extend T::Sig
        extend T::Generic

        abstract!

        sig { params(bank: T.nilable(Money::Bank::VariableExchange)).void }
        def initialize(bank = nil)
          @bank = T.let(bank || Money.default_bank, Money::Bank::VariableExchange)
        end

        sig { void }
        def fetch
          rates = exchange_rates
          currencies = rates.keys

          # rate from currency to itself is always 1
          currencies.each { add_rate(_1, _1, BigDecimal('1')) }

          currencies.combination(2).each do |curr_1, curr_2|
            curr_1 = T.cast(curr_1, String)
            curr_2 = T.cast(curr_2, String)
            rate = rates.fetch(curr_2) / rates.fetch(curr_1)
            add_rate(curr_1, curr_2, rate)
          end
        end

        sig do
          params(
            from_iso: String,
            to_iso: String,
            rate: BigDecimal,
          ).void
        end
        private def add_rate(from_iso, to_iso, rate)
          @bank.add_rate(from_iso, to_iso, rate)
          return if from_iso == to_iso

          @bank.add_rate(to_iso, from_iso, 1 / rate)
        end

        sig { abstract.returns(T::Hash[String, BigDecimal]) }
        private def exchange_rates
        end
      end
    end
  end
end
