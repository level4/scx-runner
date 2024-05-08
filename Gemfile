# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in scx-runner.gemspec
# gemspec

gem "rake", "~> 13.0"

# state & diff management
gem "hana"
gem "json-canonicalization", "~> 0.3.2"
gem "json-diff"

# some basic context parsing
gem "dry-monads"
gem "dry-schema"

# testing
gem "o_stream_catcher"
gem "subprocess"

# crypto
gem "ed25519"

# a decent server
gem "puma"

group :development, :test do
  gem "rack-test"
  gem "rspec", "~> 3.13"
  gem "rubocop", "~> 1.63.4"
end
