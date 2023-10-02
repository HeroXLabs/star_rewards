defmodule StarRewardsTest do
  use ExUnit.Case

  describe "Consumes stars with a single group" do
    test "when there are enough stars" do
      block = new_block(1, 10)
      blocks = [block]

      assert StarRewards.consume_stars(blocks, 5) ==
               {:ok,
                %StarRewards.Transaction{
                  consumed: [
                    %StarRewards.Transaction.Consumed{
                      block_id: 1,
                      amount_consumed: 5,
                      block: %{block | amount: 5}
                    }
                  ],
                  amount: 5
                }}
    end

    test "returns error when there are not enough stars" do
      blocks = [new_block(1, 10)]
      assert StarRewards.consume_stars(blocks, 15) == {:error, :not_enough_stars}
    end
  end

  describe "Consumes stars with multiple groups" do
    test "when there are enough stars" do
      block1 = new_block(1, 10)
      block2 = new_block(2, 10, 2)
      blocks = [block1, block2]

      assert StarRewards.consume_stars(blocks, 15) ==
               {:ok,
                %StarRewards.Transaction{
                  consumed: [
                    %StarRewards.Transaction.Consumed{
                      block_id: 1,
                      amount_consumed: 10,
                      block: %{block1 | amount: 0}
                    },
                    %StarRewards.Transaction.Consumed{
                      block_id: 2,
                      amount_consumed: 5,
                      block: %{block2 | amount: 5}
                    }
                  ],
                  amount: 15
                }}
    end

    test "when there are enough stars but always consume stars group expires first" do
      block1 = new_block(1, 10)
      block2 = new_block(2, 10, 2)
      blocks = [block1, block2]

      assert StarRewards.consume_stars(blocks, 15) ==
               {:ok,
                %StarRewards.Transaction{
                  consumed: [
                    %StarRewards.Transaction.Consumed{
                      block_id: 1,
                      amount_consumed: 10,
                      block: %{block1 | amount: 0}
                    },
                    %StarRewards.Transaction.Consumed{
                      block_id: 2,
                      amount_consumed: 5,
                      block: %{block2 | amount: 5}
                    }
                  ],
                  amount: 15
                }}
    end

    test "returns error when there are not enough stars" do
      block1 = new_block(1, 10)
      block2 = new_block(2, 10, 2)
      blocks = [block1, block2]

      assert StarRewards.consume_stars(blocks, 25) == {:error, :not_enough_stars}
    end
  end

  defp new_block(id, amount, expire_days \\ 1) do
    %StarRewards.Block{
      id: id,
      amount: amount,
      expires_at: later_time(expire_days)
    }
  end

  defp later_time(n) do
    DateTime.utc_now() |> DateTime.add(n, :day)
  end
end
