RSpec.describe Subscription do
  before(:all) do
    #Disable foreign key constraint
    DB.execute("PRAGMA foreign_keys = OFF;")
  end

  after(:all) do
    #Enable foreign key constraint
    DB.execute("PRAGMA foreign_keys = ON;")
  end

  describe ".retrieve_followers" do
      it "shows a list of followers of the account" do
        followers = described_class.retrieve_followers("user") #See : models/subscription.rb
        expect(followers[0]).to eq("user2")
      end
  end

  describe ".retrieve_followers_count" do
    it "shows the number of followers of the account" do
      followers_count = described_class.get_followers_count("user") #See : models/subscription.rb
      expect(followers_count).to eq(1)
    end
  end

  describe ".retrieve_followings" do
    it "shows a list of the account's followings" do
      followings = described_class.retrieve_followings("user2") #See : models/subscription.rb
      expect(followings[0]).to eq("user")
    end
  end

  describe ".retrieve_followings_count" do
    it "shows the number of followings of the account" do
      followings_count = described_class.get_followings_count("user2") #See : models/subscription.rb
      expect(followings_count).to eq(1)
    end
  end

end