defmodule StarRewards.StarRewardBuilder.Live do
  use TypedStruct
  alias StarRewards.NewStarReward

  typedstruct enforce: true do
    field :id_generator, (() -> String.t())
  end

  def new_star_reward(%__MODULE__{} = builder, reference, timezone) do
    %NewStarReward{
      id: builder.id_generator.(),
      timezone: timezone,
      reference: reference
    }
  end

  defimpl StarRewards.StarRewardBuilder, for: __MODULE__ do
    alias StarRewards.StarRewardBuilder.Live, as: Builder

    def new_star_reward(builder, reference, timezone) do
      Builder.new_star_reward(builder, reference, timezone) |> ZIO.return()
    end
  end
end
