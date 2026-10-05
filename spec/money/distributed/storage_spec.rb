# typed: false
# frozen_string_literal: true

require 'spec_helper'

describe Money::Distributed::Storage do
  subject { described_class.new(redis, ttl) }

  let(:redis) { Redis.new }
  let(:ttl) { 3600 }

  it 'stores rates in redis' do
    subject.add_rate 'USD', 'RUB', BigDecimal('60.123')
    expect(redis.hget(described_class::REDIS_KEY, 'USD_TO_RUB')).to eq('0.60123e2')
  end

  it 'gets rates from redis' do
    redis.hset(described_class::REDIS_KEY, 'USD_TO_RUB', 60.123)
    expect(subject.get_rate('USD', 'RUB')).to eq 60.123
  end

  it 'caches rates in memory' do
    redis.hset(described_class::REDIS_KEY, 'USD_TO_RUB', 60.123)
    subject.get_rate('USD', 'RUB')
    redis.hset(described_class::REDIS_KEY, 'USD_TO_RUB', 70.456)

    expect(subject.get_rate('USD', 'RUB')).to eq 60.123
  end

  it 'clears rates cache after ttl' do
    redis.hset(described_class::REDIS_KEY, 'USD_TO_RUB', 60.123)
    subject.get_rate('USD', 'RUB')
    redis.hset(described_class::REDIS_KEY, 'USD_TO_RUB', 70.456)

    Timecop.freeze(Time.now + ttl + 1)
    expect(subject.get_rate('USD', 'RUB')).to eq 70.456
  end

  context 'when multiple threads' do
    let(:storage) { subject }
    let(:rates) do
      {
        'USD_TO_EUR' => BigDecimal('0.85'),
        'EUR_TO_USD' => BigDecimal('1.18'),
      }
    end

    before do
      rates.each do |key, rate|
        redis.hset(described_class::REDIS_KEY, key, rate.to_s)
      end
    end

    # rubocop:disable RSpec/ExampleLength
    it 'maintains cache consistency with concurrent reads and writes' do
      storage.clear_cache

      threads = []
      10.times do
        threads << Thread.new do
          100.times do
            key, rate = rates.to_a.sample
            iso_from, iso_to = key.split(described_class::INDEX_KEY_SEPARATOR)
            storage.add_rate(iso_from, iso_to, rate)
            expect(storage.get_rate(iso_from, iso_to)).to eq(BigDecimal(rate))
          end
        end
      end

      threads.each(&:join)

      rates.each do |key, rate|
        expect(storage.get_rate(*key.split(described_class::INDEX_KEY_SEPARATOR)))
          .to eq(BigDecimal(rate))
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
