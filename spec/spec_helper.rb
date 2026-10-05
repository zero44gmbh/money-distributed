# typed: true
# frozen_string_literal: true

require 'rspec'
require 'concurrent-ruby'
require 'money-distributed'
require 'timecop'

RSpec.configure do |c|
  c.order = :random
  c.filter_run :focus
  c.run_all_when_everything_filtered = true

  c.after do
    Timecop.return
  end
end
