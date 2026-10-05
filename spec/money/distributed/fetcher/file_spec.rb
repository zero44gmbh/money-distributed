# typed: false
# frozen_string_literal: true

require 'spec_helper'

describe Money::Distributed::Fetcher::File do
  subject { described_class.new(file_path, bank) }

  let(:file_path) { File.expand_path('../../../fixtures/rates.txt', __dir__) }
  let(:bank) { Money::Bank::VariableExchange.new }

  before do
    allow(bank).to receive(:add_rate).and_call_original
  end

  it 'fetches rates from the file' do
    subject.fetch

    # trivial
    expect(bank).to have_received(:add_rate).with('USD', 'USD', BigDecimal('1.0'))
    expect(bank).to have_received(:add_rate).with('AUD', 'AUD', BigDecimal('1.0'))
    expect(bank).to have_received(:add_rate).with('EUR', 'EUR', BigDecimal('1.0'))

    # non-trivial combinations
    expect(bank).to have_received(:add_rate).with('USD', 'AUD', BigDecimal('1.320898'))
    expect(bank).to have_received(:add_rate).with('AUD', 'USD', 1 / BigDecimal('1.320898'))
    expect(bank).to have_received(:add_rate).with('USD', 'EUR', BigDecimal('0.907601'))
    expect(bank).to have_received(:add_rate).with('EUR', 'USD', 1 / BigDecimal('0.907601'))
    expect(bank).to have_received(:add_rate).with('AUD', 'EUR', BigDecimal('0.907601') / BigDecimal('1.320898'))

    # @NOTE: due to precision, 1/(a/b) != b/a
    expect(bank).to have_received(:add_rate).with('EUR', 'AUD', 1 / (BigDecimal('0.907601') / BigDecimal('1.320898')))
  end
end
