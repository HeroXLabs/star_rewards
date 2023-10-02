defmodule StarRewards.Block do
  use TypedStruct

  typedstruct enforce: true do
    field :id, term
    field :amount, non_neg_integer()
    field :expires_at, DateTime.t()
  end
end
