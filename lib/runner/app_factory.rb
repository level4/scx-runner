# frozen_string_literal: true

class AppFactory
  def self.create(context:, state:)
    processed_state = ALN.decode_hash(state)
    App.new(context: context, state: processed_state)
  end
end
