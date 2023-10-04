defmodule StarRewards.StarRewardBuilder.Live do
  use TypedStruct
  alias StarRewards.NewStarReward

  require ZIO

  typedstruct enforce: true do
    field :random_id, any
  end

  def new_star_reward(%__MODULE__{} = builder, reference, timezone) do
    ZIO.m do
      id <- builder.random_id
      return %NewStarReward{
        id: id,
        timezone: timezone,
        reference: reference
      }
    end
  end

  defimpl StarRewards.StarRewardBuilder, for: __MODULE__ do
    alias StarRewards.StarRewardBuilder.Live, as: Builder

    def new_star_reward(builder, reference, timezone) do
      Builder.new_star_reward(builder, reference, timezone)
    end
  end
end
