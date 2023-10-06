defmodule StarRewards.Repository do
  alias StarRewards.{NewStarReward, StarReward, NewBlock, Block, Transaction}

  @type star_reward_id :: String.t()
  @type consume_fn :: ((StarReward.t(), non_neg_integer()) -> {:ok, Transaction.t()} | {:error, :not_enough_stars})

  @callback create_star_reward(NewStarReward.t()) :: ZIO.zio(any, any, StarReward.t())
  @callback find_star_reward(star_reward_id) :: ZIO.zio(any, any, StarReward.t())
  @callback create_block(star_reward_id, NewBlock.t()) :: ZIO.zio(any, any, Block.t())

  @callback create_transaction(star_reward_id, non_neg_integer, DateTime.t(), consume_fn) :: any
end
