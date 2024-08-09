require "rspec"

RSpec.describe "Writing Story View" do
  
  before(:all) do
    DB.execute("PRAGMA foreign_keys = OFF;")
  end

  after(:all) do
    DB.execute("PRAGMA foreign_keys = ON;")
  end

  describe "when user creates a story" do
    it "saves the story to a database" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value
      post "/sendStory", {"title" => "test_title", "genres" => "Adventure", "price" => "40", "story_content" => "djfshdfjsd", "language" => "English"}, {"rack.session" => session}
      story = Story.first(story_id: 1)
      expect(story).not_to be_nil
      expect(story.title).to eq("test_title")
      expect(story.genre).to eq("Adventure")
      expect(story.cost).to eq(40)
      expect(story.content).to eq("djfshdfjsd")
      expect(story.language).to eq("English")
    end
  end
end