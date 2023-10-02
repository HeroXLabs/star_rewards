defmodule StarRewards do
  use TypedStruct
  alias __MODULE__.{Block, Transaction}

  typedstruct enforce: true do
    field :id, term
    field :owner_id, term
    field :blocks, [Block.t()]
  end

  @spec consume_stars([Block.t()], non_neg_integer()) ::
          {:ok, Transaction.t()} | {:error, :not_enough_stars}
  def consume_stars(blocks, count) do
    consumed = []
    remaining_count = count

    total_stars =
      blocks |> Enum.map(& &1.amount) |> Enum.sum()

    if total_stars < count do
      {:error, :not_enough_stars}
    else
      ordered_blocks =
        blocks
        |> Enum.sort_by(& &1.expires_at)

      {consumed, _} =
        Enum.reduce(ordered_blocks, {consumed, remaining_count}, fn block,
                                                                           {consumed,
                                                                            remaining_count} ->
          if remaining_count > 0 do
            if block.amount >= remaining_count do
              consumed =
                consumed ++
                  [
                    %Transaction.Consumed{
                      block_id: block.id,
                      amount_consumed: remaining_count,
                      block: %{block | amount: block.amount - remaining_count}
                    }
                  ]

              {consumed, 0}
            else
              consumed =
                [
                  %Transaction.Consumed{
                    block_id: block.id,
                    amount_consumed: block.amount,
                    block: %{block | amount: 0}
                  }
                ] ++ consumed

              remaining_count = remaining_count - block.amount
              {consumed, remaining_count}
            end
          else
            {consumed, remaining_count}
          end
        end)

      {:ok, %Transaction{consumed: consumed, amount: count}}
    end
  end
end
