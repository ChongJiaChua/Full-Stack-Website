class Subscription < Sequel::Model


  def self.retrieve_followers(user)
    return Subscription.where(subscribed_account: user).map(:subscriber)
  end

  def self.get_followers_count(user)
    return Subscription.where(subscribed_account: user).count
  end

  def self.retrieve_followings(user)
    return Subscription.where(subscriber: user).map(:subscribed_account)
  end

  def self.get_followings_count(user)
    return Subscription.where(subscriber: user).count
  end


end