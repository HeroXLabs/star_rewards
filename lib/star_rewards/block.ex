defmodule StarRewards.Block do
  use TypedStruct

  typedstruct enforce: true do
    field :id, term
    field :amount, non_neg_integer()
    field :amount_left, non_neg_integer()
    field :reference, String.t()
    field :created_at, DateTime.t()
    field :expire_date, Date.t()
  end
end
