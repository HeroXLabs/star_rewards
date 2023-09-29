defmodule StarRewardsTest do
  use ExUnit.Case

  describe "Consumes stars with a single group" do
    test "when there are enough stars" do
      stars_group = new_stars_group(1, 10)
      stars_groupes = [stars_group]

      assert StarRewards.consume_stars(stars_groupes, 5) ==
               {:ok,
                %StarRewards.Transaction{
                  consumed: [
                    %StarRewards.Transaction.Consumed{
                      stars_group_id: 1,
                      amount_consumed: 5,
                      stars_group: %{stars_group | amount: 5}
                    }
                  ],
                  amount: 5
                }}
    end

    test "returns error when there are not enough stars" do
      stars_groupes = [new_stars_group(1, 10)]
      assert StarRewards.consume_stars(stars_groupes, 15) == {:error, :not_enough_stars}
    end
  end

  describe "Consumes stars with multiple groups" do
    test "when there are enough stars" do
      stars_group1 = new_stars_group(1, 10)
      stars_group2 = new_stars_group(2, 10, 2)
      stars_groupes = [stars_group1, stars_group2]

      assert StarRewards.consume_stars(stars_groupes, 15) ==
               {:ok,
                %StarRewards.Transaction{
                  consumed: [
                    %StarRewards.Transaction.Consumed{
                      stars_group_id: 1,
                      amount_consumed: 10,
                      stars_group: %{stars_group1 | amount: 0}
                    },
                    %StarRewards.Transaction.Consumed{
                      stars_group_id: 2,
                      amount_consumed: 5,
                      stars_group: %{stars_group2 | amount: 5}
                    }
                  ],
                  amount: 15
                }}
    end

    test "when there are enough stars but always consume stars group expires first" do
      stars_group1 = new_stars_group(1, 10)
      stars_group2 = new_stars_group(2, 10, 2)
      stars_groupes = [stars_group1, stars_group2]

      assert StarRewards.consume_stars(stars_groupes, 15) ==
               {:ok,
                %StarRewards.Transaction{
                  consumed: [
                    %StarRewards.Transaction.Consumed{
                      stars_group_id: 1,
                      amount_consumed: 10,
                      stars_group: %{stars_group1 | amount: 0}
                    },
                    %StarRewards.Transaction.Consumed{
                      stars_group_id: 2,
                      amount_consumed: 5,
                      stars_group: %{stars_group2 | amount: 5}
                    }
                  ],
                  amount: 15
                }}
    end

    test "returns error when there are not enough stars" do
      stars_group1 = new_stars_group(1, 10)
      stars_group2 = new_stars_group(2, 10, 2)
      stars_groupes = [stars_group1, stars_group2]

      assert StarRewards.consume_stars(stars_groupes, 25) == {:error, :not_enough_stars}
    end
  end

  defp new_stars_group(id, amount, expire_days \\ 1) do
    %StarRewards.StarsGroup{
      id: id,
      amount: amount,
      expires_at: later_time(expire_days)
    }
  end

  defp later_time(n) do
    DateTime.utc_now() |> DateTime.add(n, :day)
  end
end
