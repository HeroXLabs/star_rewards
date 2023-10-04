defmodule StarRewards.StarReward do
  alias StarRewards.Block
  use TypedStruct

  typedstruct enforce: true do
    field :id, term
    field :reference, String.t()
    field :timezone, String.t()
    field :blocks, [Block.t()]
    field :created_at, DateTime.t()
  end
end
