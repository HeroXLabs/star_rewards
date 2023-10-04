defmodule StarRewards.NewBlock do
  use TypedStruct

  typedstruct enforce: true do
    field :id, term
    field :amount, non_neg_integer()
    field :reference, String.t()
    field :expire_date, Date.t()
  end
end
