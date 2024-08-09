# SimpleCov
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end
SimpleCov.coverage_dir "coverage"

# Sinatra App
ENV["APP_ENV"] = "test"
require_relative "../app"
def app
  Sinatra::Application
end

#Capybara
require "capybara/rspec"
Capybara.app = Sinatra::Application

# RSpec
require "require_all"
require_rel "../models"
RSpec.configure do |config|
    config.include Capybara::DSL
    config.include Rack::Test::Methods
  
    # before each test is run, delete all records and create a user in the user table
    config.before do
      User.dataset.delete
      Story.dataset.delete
      Poll.dataset.delete
      Subscription.dataset.delete
      Poll.dataset.delete
      Wishlist.dataset.delete
      StoryDislike.dataset.delete
      StoryLike.dataset.delete
      Pollvote.dataset.delete
      Reading.dataset.delete
      Wishlist.dataset.delete  
      CensoredWords.dataset.delete


      testUser = User.new()
      testUser.user_name = "user"
      testUser.account_type = "customer"
      testUser.encrypt({"newPassword" => "user1!"})
      testUser.password = testUser.getDataCrypt()
      testUser.email = "user@email.com"
      testUser.popcorn = 100
      testUser.compound = 100.0
      testUser.premium = 0
      testUser.iv = testUser.getIv()
      testUser.salt = testUser.getSalt()
      testUser.creation_date = Date.today.to_s
      testUser.save_changes

      testUser2 = User.new()
      testUser2.user_name = "user2"
      testUser2.account_type = "customer"
      testUser2.encrypt({"newPassword" => "user1!"})
      testUser2.password = testUser2.getDataCrypt()
      testUser2.email = "user2@email.com"
      testUser2.popcorn = 100
      testUser2.compound = 100.0
      testUser2.premium = 0
      testUser2.iv = testUser2.getIv()
      testUser2.salt = testUser2.getSalt()
      testUser2.creation_date = Date.today.to_s
      testUser2.save_changes

      testUser3 = User.new()
      testUser3.user_name = "admin"
      testUser3.account_type = "admin"
      testUser3.encrypt({"newPassword" => "admin1!"})
      testUser3.password = testUser3.getDataCrypt()
      testUser3.email = "admin@email.com"
      testUser3.popcorn = 100
      testUser3.compound = 100.0
      testUser3.premium = 0
      testUser3.iv = testUser3.getIv()
      testUser3.salt = testUser3.getSalt()
      testUser3.creation_date = Date.today.to_s
      testUser3.save_changes

      Subscription.insert(subscriber: testUser.user_name, subscribed_account: testUser2.user_name)
      Subscription.insert(subscriber: testUser2.user_name, subscribed_account: testUser.user_name)
      
      testPoll = Poll.new()
      testPoll.id = 0
      testPoll.title = "testPoll"
      testPoll.qa = Sequel.blob("This is a test?/yes no maybe.")
      testPoll.story = 0
      testPoll.save_changes

      testStory = Story.new()
      testStory.story_id = 0
      testStory.title = "test"
      testStory.content = Sequel.blob("This is a test!")
      testStory.genre = "Adventure"
      testStory.language = "English"
      testStory.author = "user"
      testStory.cost = 20
      testStory.likes = 0
      testStory.dislikes = 0
      testStory.save_changes

      
      Reading.insert(reader: testUser.user_name, stories_reading: testStory.story_id.to_s)

      Wishlist.insert(reader: "user", stories_wishlist: 0)

      CensoredWords.insert(word: "fuck")

    end

    config.after do 
      User.dataset.delete
      Story.dataset.delete
      Poll.dataset.delete
      Subscription.dataset.delete
      Poll.dataset.delete
      Wishlist.dataset.delete
      StoryDislike.dataset.delete
      StoryLike.dataset.delete
      Pollvote.dataset.delete
      Reading.dataset.delete
      Wishlist.dataset.delete
      CensoredWords.dataset.delete
    end
  end



def add_test_user() 
  testUser = User.new()
  testUser.user_name = "user"
  testUser.account_type = "customer"
  testUser.password = testUser.encrypt({"newPassword" => "user1!"})
  testUser.email = "user@email.com"
  testUser.popcorn = 100
  testUser.compound = 100.0
  testUser.premium = 0
  testUser.iv = testUser.getIv()
  testUser.salt = testUser.getSalt()
  testUser.creation_date = Date.today.to_s
  testUser.save_changes
  testUser

  testUser2 = User.new()
  testUser2.user_name = "user2"
  testUser2.account_type = "customer"
  testUser2.password = testUser2.encrypt({"newPassword" => "user1!"})
  testUser2.email = "user2@email.com"
  testUser2.popcorn = 100
  testUser2.compound = 100.0
  testUser2.premium = 0
  testUser2.iv = testUser2.getIv()
  testUser2.salt = testUser2.getSalt()
  testUser2.creation_date = Date.today.to_s
  testUser2.save_changes
  testUser2

  Subscription.insert(subscriber: testUser.user_name, subscribed_account: testUser2.user_name)
  Subscription.insert(subscriber: testUser2.user_name, subscribed_account: testUser.user_name)

end



def add_test_story()
  testStory = Story.new()
  testStory.story_id = "0"
  testStory.title = "test"
  testStory.content = Sequel.blob("This is a test!")
  testStory.genre = "Adventure"
  testStory.author = "user"
  testStory.cost = 0

  Reading.insert(reader: "user", stories_reading: testStory.story_id)
end


