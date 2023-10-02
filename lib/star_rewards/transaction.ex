defmodule StarRewards.Transaction do
  use TypedStruct
  alias StarRewards.Block

  defmodule Consumed do
    use TypedStruct

    typedstruct enforce: true do
      field :block_id, term
      field :amount_consumed, non_neg_integer()
      field :block, Block.t()
    end
  end

  typedstruct enforce: true do
    field :consumed, [Consumed.t()]
    field :amount, non_neg_integer()
  end
end
