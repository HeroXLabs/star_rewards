defprotocol StarRewards.Repository do
  def find_or_create_star_rewards(repo, owner_id)

  def create_block(repo, block)

  def create_transation(repo, transaction)
end
