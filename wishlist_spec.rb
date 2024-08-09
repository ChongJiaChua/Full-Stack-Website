RSpec.describe Wishlist do
  before(:all) do
    DB.execute("PRAGMA foreign_keys = OFF;")
  end

  after(:all) do
    DB.execute("PRAGMA foreign_keys = ON;")
  end

  describe ".retrieve_story" do
    it "retrieve the list of stories wishlisted" do
      story_id = 0
      story_title = "test"
      retrieved_stories = described_class.retrieve_story("user")

      expect(retrieved_stories[0]).to eq([story_id, story_title])
    end
  end
end