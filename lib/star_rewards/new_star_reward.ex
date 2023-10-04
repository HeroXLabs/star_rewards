defmodule StarRewards.NewStarReward do
  use TypedStruct

  typedstruct enforce: true do
    field :id, term
    field :timezone, String.t()
    field :reference, String.t()
  end
end
