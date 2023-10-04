defmodule StarRewards.BlockBuilder.Live do
  use TypedStruct
  alias StarRewards.NewBlock

  typedstruct enforce: true do
    field :id_generator, (() -> String.t())
    field :expire_method, {:month, non_neg_integer} | {:day, non_neg_integer}
  end

  def new_block(%__MODULE__{} = builder, amount, reference, timezone, %DateTime{} = utc_now) do
    date = date_on_timezone(utc_now, timezone)
    expire_date = find_expiration_date(date, builder.expire_method)

    %NewBlock{
      id: builder.id_generator.(),
      amount: amount,
      reference: reference,
      expire_date: expire_date
    }
  end

  defp find_expiration_date(date, {:month, expire_in_months}) do
    date
    |> first_date_of_month()
    |> Date.add(approximate_days_in_months(expire_in_months))
    |> first_date_of_month()
  end

  defp find_expiration_date(date, {:day, expire_in_days}) do
    date
    |> Date.add(expire_in_days)
  end

  defp date_on_timezone(%DateTime{} = dt, timezone) do
    dt
    |> Calendar.DateTime.shift_zone!(timezone)
    |> DateTime.to_date()
  end

  defp first_date_of_month(%Date{} = date) do
    {:ok, date} = Date.new(date.year, date.month, 1)
    date
  end

  defp approximate_days_in_months(months) do
    months * 31
  end

  defimpl StarRewards.BlockBuilder, for: __MODULE__ do
    alias StarRewards.BlockBuilder.Live, as: Builder

    def new_block(builder, amount, reference, timezone, utc_now) do
      Builder.new_block(builder, amount, reference, timezone, utc_now) |> ZIO.return()
    end
  end
end
