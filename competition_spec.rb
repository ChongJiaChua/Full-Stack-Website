require 'spec_helper'
require 'rack/test'

RSpec.describe "Competition Feature", type: :request do
  include Rack::Test::Methods
  class Story < Sequel::Model
    unrestrict_primary_key

    one_to_many :likes, class: :StoryLike, key: :liked_story_id
    one_to_many :dislikes, class: :StoryDislike, key: :disliked_story_id
  end

  class StoryLike < Sequel::Model
    many_to_one :story, key: :liked_story_id
  end

  class StoryDislike < Sequel::Model
    many_to_one :story, key: :disliked_story_id
  end

  class User < Sequel::Model
    unrestrict_primary_key
  end

  class Reading < Sequel::Model
    unrestrict_primary_key
  end

  before(:all) do
    # Disable foreign key constraints if necessary
    DB.run("PRAGMA foreign_keys = OFF;")
  end

  after(:all) do
    # Re-enable foreign key constraints
    DB.run("PRAGMA foreign_keys = ON;")
  end

  before do
    DB.transaction do
      DB[:users].delete
      DB[:readings].delete
      DB[:competition].delete
      DB[:stories].delete
    end

    5.times { |i| Story.create(title: "Story #{i + 1}") }

    user1 = User.create(user_name: 'user1', popcorn: 0)
    user2 = User.create(user_name: 'user2', popcorn: 0)

    3.times { |i| Reading.create(reader: 'user1', stories_reading: Story[i + 1].id) }
    2.times { |i| Reading.create(reader: 'user2', stories_reading: Story[i + 4].id) }

    DB[:competition].insert(competition_date: (Date.today - 1).to_s, winner: 'user1', runner_up: 'user2')
  end

  it "should load the home page and handle competition logic on the last day of the month" do
    allow(Date).to receive(:today).and_return(Date.new(2024, 5, 31))
    get '/competition'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Competition Results")
    expect(last_response.body).to include("user1 with 3 stories read.")
    expect(last_response.body).to include("Runner-up:")
    expect(last_response.body).to include("user2 with 2 stories read.")
  end

  it "should handle cases where no readers have participated" do
    DB[:readings].delete

    allow(Date).to receive(:today).and_return(Date.new(2024, 6, 30))
    get '/competition'

    expect(last_response).to be_ok
    competition = DB[:competition].where(competition_date: '2024-06-30').first
    expect(competition).to be_nil
    expect(last_response.body).to include("No competition results to display.")
  end

  it "should not calculate results if today is not the last day of the month" do
    DB[:competition].delete
    allow(Date).to receive(:today).and_return(Date.new(2024, 6, 15))
    get '/competition'

    expect(last_response).to be_ok
    competition = DB[:competition].where(competition_date: '2024-06-15').first
    expect(competition).to be_nil
    expect(last_response.body).to include("No competition results to display.")
  end
end