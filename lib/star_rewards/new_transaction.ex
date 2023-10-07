defmodule StarRewards.NewTransaction do
  use TypedStruct
  alias StarRewards.Block

  defmodule Consumed do
    use TypedStruct

    @derive {Jason.Encoder, only: [:block_id, :amount_consumed]}
    typedstruct enforce: true do
      field :block_id, term
      field :amount_consumed, non_neg_integer()
      field :block, Block.t()
    end
  end

  @derive Jason.Encoder
  typedstruct enforce: true do
    field :consumed, [Consumed.t()]
    field :amount, non_neg_integer()
  end
end
