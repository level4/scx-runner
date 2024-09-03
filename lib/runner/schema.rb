# frozen_string_literal: true

require "dry-schema"

RequestSchema = Dry::Schema.JSON do
  required(:context).filled(:hash)
  required(:state).maybe(:hash)
end

UserSchema = Dry::Schema.JSON do
  required(:id).filled(:string)
  required(:keys).filled(:hash)
  required(:balance).filled(:string)
  required(:groups).filled(:hash)
  optional(:rules).filled(:hash)
end

CallSchema = Dry::Schema.JSON do
  required(:id).filled(:string)
  required(:target).filled(:string)
  required(:function).filled(:string)
  optional(:args).maybe(:hash)
  required(:ttl).filled(:integer)
end

ContextSchemaFull = Dry::Schema.JSON do # rubocop:disable Metrics/BlockLength
  required(:call).filled(CallSchema)

  required(:caller).schema do
    optional(:user).maybe(UserSchema)
    required(:key).filled(:string)
  end

  required(:system).schema do
    required(:system).schema do
      required(:key).filled(:string)
    end
    required(:root).schema do
      required(:key).filled(:string)
    end
  end

  optional(:v).filled(:float)

  required(:calldata).schema do
    required(:call).schema do
      required(:args).filled(:hash)
      required(:function).filled(:string)
      required(:id).filled(:string)
      required(:ttl).filled(:integer)
      required(:target).filled(:string)
    end
    required(:meta).schema do
      required(:hash).filled(:string)
      required(:state_key).filled(:string)
      required(:hash12).filled(:string)
    end
    optional(:requirements).array(:hash)
    required(:base58).filled(:string)
    required(:law).filled(:string)
    required(:operations).array do
      schema do
        required(:parent).filled(:string)
        required(:continue).filled(:string)
        required(:success).filled(:bool)
        required(:action).filled(:string)
        required(:actor).filled(:string)
        required(:mutating).filled(:bool)
        required(:fee).filled(:float)
      end
    end
    optional(:confirmations).array do
      schema do
        required(:type).filled(:string)
        required(:signature).filled(:string)
        required(:key).filled(:string)
        required(:signer).filled(:string)
      end
    end
    optional(:segwit).array do
      schema do
        required(:parent).filled(:string)
        required(:host).filled(:string)
        optional(:witnesses).array do
          schema do
            optional(:type).maybe(:string)
            required(:signature).filled(:string)
            optional(:key).maybe(:string)
            required(:signer).filled(:string)
          end
        end
        required(:current).filled(:string)
      end
    end
  end

  required(:signers).array(UserSchema)
end

ContextSchemaBasic = Dry::Schema.Params do
  required(:call).filled(CallSchema)
  required(:caller).filled(:hash)

  optional(:targets).maybe(:array)
end
