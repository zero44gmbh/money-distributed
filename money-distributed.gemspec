# -*- encoding: utf-8 -*-
# stub: money-distributed 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "money-distributed".freeze
  s.version = "0.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["DarthSim".freeze]
  s.date = "1980-01-02"
  s.email = ["darthsim@gmail.com".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze, "lib/money".freeze, "lib/money-distributed.rb".freeze, "lib/money/distributed".freeze, "lib/money/distributed/fetcher".freeze, "lib/money/distributed/fetcher/base.rb".freeze, "lib/money/distributed/fetcher/file.rb".freeze, "lib/money/distributed/read_write_lock.rb".freeze, "lib/money/distributed/redis.rb".freeze, "lib/money/distributed/storage.rb".freeze, "lib/money/distributed/version.rb".freeze, "sorbet/rbi/dsl/active_support/callbacks.rbi".freeze, "sorbet/rbi/shims/money/distributed/fetcher/base.rbi".freeze]
  s.homepage = "https://github.com/DarthSim/money-distributed".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "4.0.21".freeze
  s.summary = "Money gem extension for distributed systems".freeze

  s.installed_by_version = "4.0.21".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<connection_pool>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<money>.freeze, [">= 6.6.0".freeze])
  s.add_runtime_dependency(%q<redis>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<sorbet>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<sorbet-runtime>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 12.3.3".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["= 1.49.0".freeze])
  s.add_development_dependency(%q<rubocop-dbl>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<spoom>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<tapioca>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0".freeze])
end
