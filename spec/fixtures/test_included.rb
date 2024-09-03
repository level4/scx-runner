require_relative "../../lib/runner"

class TestIncluded
  include Runner

  def method_with_args(arg1)
    "arg1: #{arg1}"
  end

  def method_with_auth_check
    "unauthorised" unless groups["admins"].include?(caller)
  end
end

TestIncluded.new.run_system
