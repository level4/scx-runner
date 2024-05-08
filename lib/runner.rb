# frozen_string_literal: true

require_relative "runner/version"
require_relative "runner/dispatch"
require_relative "runner/context"
require "json"
require "hana"

require "json-diff"

module Runner
  class Error < StandardError
  end
end
