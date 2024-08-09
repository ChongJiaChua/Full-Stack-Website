RSpec.describe Reading do
  before(:all) do
    DB.execute("PRAGMA foreign_keys = OFF;")

  end

  after(:all) do
    DB.execute("PRAGMA foreign_keys = ON;")
  end

  before do
    @user = User.create(user_name: "test_user", popcorn: 100)
    @author = User.create(user_name: "author", popcorn: 50)
    @story = Story.create(story_id: 1, title: "Test Story", author: @author.user_name, cost: 20)
    Reading.truncate 
  end

  after do
    User.truncate
    Story.truncate
    Reading.truncate
  end

  class User < Sequel::Model
    unrestrict_primary_key
  end

  class Story < Sequel::Model
    unrestrict_primary_key

    one_to_many :likes, class: :StoryLike, key: :liked_story_id
    one_to_many :dislikes, class: :StoryDislike, key: :disliked_story_id
  end

  describe "POST /buy" do
    let(:session_data) do
      {
        "logged_in" => true,
        "user" => @user.user_name,
        "story_id" => @story.story_id
      }
    end

    context "when the user has enough popcorn" do
      let(:params) do
        {
          "story_price" => @story.cost.to_s,
          "story_title" => @story.title
        }
      end

      it "deducts the story cost from the user's popcorn and updates the author" do
        post "/buy", params, { "rack.session" => session_data }

        @user.reload
        @author.reload
        purchased_story = Reading.first(reader: @user.user_name, stories_reading: @story.story_id)

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/reading_page?id=#{@story.story_id}")
        expect(@user.popcorn).to eq(80) 
        expect(@author.popcorn).to eq(70) 
        expect(purchased_story).not_to be_nil
      end
    end

    context "when the user does not have enough popcorn" do
      let(:params) do
        {
          "story_price" => (@user.popcorn + 10).to_s,
          "story_title" => @story.title
        }
      end

      it "redirects to the payment page with a price error" do
        post "/buy", params, { "rack.session" => session_data }

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/payment")
      end
    end

    context "when the user is not logged in" do
      let(:params) do
        {
          "story_price" => @story.cost.to_s,
          "story_title" => @story.title
        }
      end
      let(:session_data) { { "logged_in" => false } }

      it "redirects to the login page" do
        post "/buy", params, { "rack.session" => session_data }

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/login")
      end
    end
  end
end