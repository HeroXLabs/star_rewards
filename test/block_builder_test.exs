defmodule StarRewards.BlockBuilderTest do
  use ExUnit.Case
  alias StarRewards.Block
  alias StarRewards.NewBlock
  alias StarRewards.BlockBuilder

  @timezone "America/Los_Angeles"

  describe "#new_block" do
    test "with month expire method" do
      builder = %BlockBuilder.Live{
        random_id: ZIO.return(1),
        expire_method: {:month, 4}
      }

      assert new_block(builder, 10, "Purchase", @timezone, utc_now()) == %NewBlock{
        id: 1,
        amount: 10,
        reference: "Purchase",
        expire_date: ~D[2021-05-01]
      }
    end

    test "with day expire method" do
      builder = %BlockBuilder.Live{
        random_id: ZIO.return(1),
        expire_method: {:day, 4}
      }

      assert new_block(builder, 10, "Purchase", @timezone, utc_now()) == %NewBlock{
        id: 1,
        amount: 10,
        reference: "Purchase",
        expire_date: ~D[2021-01-15]
      }
    end
  end

  defp utc_now() do
    Calendar.DateTime.from_erl!({{2021, 1, 11}, {12, 0, 0}}, "America/Los_Angeles") |> Calendar.DateTime.shift_zone!("UTC")
  end

  defp new_block(builder, amount, reference, timezone, now) do
    {:ok, res} =
      BlockBuilder.Live.new_block(builder, amount, reference, timezone, now)
      |> ZIO.run_with([])
    res
  end
end
