# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in scx-runner.gemspec
gemspec

gem "rake", "~> 13.0"

# state & diff management
gem "hana"
gem 'json-diff'
gem 'json-canonicalization', '~> 0.3.2'

# testing
gem 'o_stream_catcher'
gem "subprocess"

# crypto
gem 'ed25519'

group :development, :test do
  gem "rspec", "~> 3.13"
  gem "rubocop", "~> 1.63.4"
end
