defmodule StarRewards.Transaction do
  use TypedStruct

  @derive Jason.Encoder
  typedstruct enforce: true do
    field :id, String.t()
    field :amount, non_neg_integer()
    field :created_at, DateTime.t()
  end
end
