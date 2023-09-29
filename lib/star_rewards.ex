defmodule StarRewards do
  defmodule StarsGroup do
    use TypedStruct

    typedstruct enforce: true do
      field(:id, term)
      field(:amount, non_neg_integer())
      field(:expires_at, DateTime.t())
    end
  end

  defmodule Transaction do
    use TypedStruct

    defmodule Consumed do
      use TypedStruct

      typedstruct enforce: true do
        field(:stars_group_id, term)
        field(:amount_consumed, non_neg_integer())
        field(:stars_group, StarsGroup.t())
      end
    end

    typedstruct enforce: true do
      field(:consumed, [Consumed.t()])
      field(:amount, non_neg_integer())
    end
  end

  # def list_available_stars_groupes() do
  # end

  @spec consume_stars([StarsGroup.t()], non_neg_integer()) ::
          {:ok, Transaction.t()} | {:error, :not_enough_stars}
  def consume_stars(stars_groupes, count) do
    consumed = []
    remaining_count = count

    total_stars =
      stars_groupes |> Enum.map(& &1.amount) |> Enum.sum()

    if total_stars < count do
      {:error, :not_enough_stars}
    else
      ordered_stars_groupes =
        stars_groupes
        |> Enum.sort_by(& &1.expires_at)
        |> Enum.reverse()

      {consumed, _} =
        Enum.reduce(ordered_stars_groupes, {consumed, remaining_count}, fn stars_group,
                                                                           {consumed,
                                                                            remaining_count} ->
          if remaining_count > 0 do
            if stars_group.amount >= remaining_count do
              consumed =
                consumed ++
                  [
                    %Transaction.Consumed{
                      stars_group_id: stars_group.id,
                      amount_consumed: remaining_count,
                      stars_group: %{stars_group | amount: stars_group.amount - remaining_count}
                    }
                  ]

              {consumed, 0}
            else
              consumed =
                [
                  %Transaction.Consumed{
                    stars_group_id: stars_group.id,
                    amount_consumed: stars_group.amount,
                    stars_group: %{stars_group | amount: 0}
                  }
                ] ++ consumed

              remaining_count = remaining_count - stars_group.amount
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
