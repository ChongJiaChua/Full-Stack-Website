require 'spec_helper'
require 'rspec'

RSpec.describe "Feedback Form Routes" do

  class User < Sequel::Model
    unrestrict_primary_key
  end

  class Reading < Sequel::Model
    unrestrict_primary_key
  end

  class Story < Sequel::Model
    unrestrict_primary_key
  end

  describe "GET /feedback" do
    it "loads the feedback form successfully with a valid story ID" do
      story_id = 1  
      Story.create(story_id: story_id, title: "Sample Story", content: "Sample content")  
      get "/feedback", story_id: story_id
      expect(last_response).to be_ok
      expect(last_response.body).to include("Feedback Form")
    end

    it "redirects to the home page if the story is not found" do
      get "/feedback", story_id: "invalid_id"
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to end_with("/")
    end
  end

  
  describe "POST /feedback" do
    before(:each) do
      @user = User.create(user_name: "test_user", email: "test@example.com")
      @story = Story.create(story_id: 1, title: "Sample Story", content: "Sample content")
      allow_any_instance_of(Sinatra::Base).to receive(:session).and_return({ "user" => @user.user_name })
    end
  
    it "shows an error message when the form is empty" do
      post '/feedback', {
        'story_id' => @story.story_id,
        'feedback' => '',
        'comments' => '',
        'referrer' => '/reading_page?id=1'
      }
      expect(last_response.body).to include("Please provide your feedback or comment.")
    end
  
    it "redirects to the reading page on successful submission" do
      post '/feedback', {
        'story_id' => @story.story_id,
        'feedback' => 'Great story!',
        'comments' => 'I loved the characters!',
        'referrer' => '/reading_page?id=1'
      }
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to end_with("/reading_page?id=#{@story.story_id}")
    end
  end
end