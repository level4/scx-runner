require_relative "../../lib/runner"

class TestIncluded
  include Runner

  def method_with_args(arg1)
    "arg1: #{arg1}"
  end

  def method_with_auth_check
    "unauthorised" unless groups["admins"].include?(caller)
  end

  def method_with_ext_access
    expected = 0
    result = ext_call("sc:ext:my_ext", "method_name", ["arg1"])
    raise "ext_call failed" unless result

    { "data_response" => result }
  end
end

TestIncluded.new.run_system
