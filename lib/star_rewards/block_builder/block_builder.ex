defprotocol StarRewards.BlockBuilder do
  def new_block(builder, amount, reference, timezone, utc_now)
end
