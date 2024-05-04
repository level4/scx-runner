require_relative "../../lib/scx/runner"

class TestIncluded
  include Scx::Runner

  def method_with_args(arg1)
    "arg1: #{arg1}"
  end

  def method_with_auth_check
    return "unauthorised" unless groups["admins"].include?(caller)
  end

  def method_with_ext_access
    expected = 0
    result = ext_call("sc:ext:my_ext", "method_name", ["arg1"])
    if result
      return {"data_response" => result}
    else
      raise "ext_call failed"
    end
  end
end

TestIncluded.new.run_system
