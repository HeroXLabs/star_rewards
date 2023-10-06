defmodule StarRewards do
  alias __MODULE__.{StarReward, Block, Transaction, BlockBuilder, StarRewardBuilder}
  require ZIO

  def find_star_reward(star_reward_id) do
    ZIO.m do
      repository <- ZIO.environment(:repository)
      repository.find_star_reward(star_reward_id)
    end
  end

  def create_star_reward(reference, timezone) do
    ZIO.m do
      builder <- ZIO.environment(:star_reward_builder)
      repository <- ZIO.environment(:repository)

      new_star_reward <- StarRewardBuilder.new_star_reward(builder, reference, timezone)
      repository.create_star_reward(new_star_reward)
    end
  end

  def add_stars(%StarReward{id: star_reward_id, timezone: timezone}, count, reference, %DateTime{} = utc_now) do
    ZIO.m do
      block_builder <- ZIO.environment(:block_builder)
      repository <- ZIO.environment(:repository)
      new_block <- BlockBuilder.new_block(block_builder, count, reference, timezone, utc_now)
      _ <- repository.create_block(star_reward_id, new_block)
      return :ok
    end
  end

  def consume(star_reward_id, count) do
    ZIO.m do
      repository <- ZIO.environment(:repository)
      clock <- ZIO.environment(:clock)

      star_reward <- repository.find_star_reward(star_reward_id)
      let date = clock.today(star_reward.timezone)
      repository.create_transaction(star_reward_id, count, date, &consume_stars/2) |> ZIO.from_either()
    end
  end

  @spec consume_stars(StarReward.t(), non_neg_integer()) ::
          {:ok, Transaction.t()} | {:error, :not_enough_stars}
  def consume_stars(%StarReward{blocks: blocks}, count) do
    consume_stars(blocks, count)
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
        |> Enum.sort_by(& &1.expire_date, Date)

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
