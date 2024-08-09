require "logger"
require "sequel"
require "sqlite3"

get "/profile" do
  logged_in = session["logged_in"]
  redirect "/login" if !logged_in #Routing to /profile without logging in will redirect to /login

  # find the user with the username in database as an array of object
  @username = session["user"]
  @user = User.where(user_name: session["user"]) 

  #Retrieve the count of subscribers and subscribed account
  @subscriber_count = Subscription.where(subscribed_account: @username).count
  @subscription_count = Subscription.where(subscriber: @username).count
  # find the user in the database as an object
  current_user = User.first(user_name: @username)

  # Retrieve the last purchased books from the user
  reading = Reading.where(reader: @username).last

  # Retrieve all the purchased books from the user see : models/reading.rb
  @subscribed_stories = Reading.retrieve_stories(@username)
  # Retrieve all the wishlisted books from the user see : models/wishlist.rb
  @wishlisted_stories = Wishlist.retrieve_story(@username)
  
  current_date = Date.today
  creation_date = Date.parse(current_user.creation_date) if current_user && current_user.creation_date
  #Calculate the length of account since it has been created, in months
  if creation_date != nil then
    length_of_account_months = calculate_length_of_account(current_date.year, current_date.month, 
                                                          creation_date.year, creation_date.month)
    @subscribed_stories_count_days = @subscribed_stories.length.to_f / ((current_date - creation_date).to_f)
    @subscribed_stories_count_months = @subscribed_stories.length.to_f / length_of_account_months.to_f
  end

  #Retrieve written stories
  @stories = Story.where(author: @username)
  @displayTitle = ""
  @totalVotes = ""
  @display1 = ""
  @display2 = ""
  @display3 = ""
  @seen = []
  #adding votes on poll as writer
  #finds all polls made by user, from their stories
  #finds all pollvote rows from each poll
  @storiesArray = @stories.to_a
  @storiesArray.each do |x|
    @poll = Poll.where(story: x.story_id).to_a
    if (@poll.length() == 0) then
      @displayTitle = "No Polls for #{x.title}"
      @totalVotes = ""
      @display1 = ""
      @display2 = ""
      @display3 = ""
      next
    end
    @poll.each do |u|
      @votes = Pollvote.where(poll: u.id).to_a
      @votes.each do |r|
        @ans = r.answer
        @split = @ans.split(" ")
        cnt = 0
        @numOfVotes = 0
        
        @ans1cnt = 0
        @ans2cnt = 0
        @ans3cnt = 0
        flag = true
        @split.each do |y|
          if (y != "") then
            @numOfVotes += 1
          end
          count = 0
          while (count < @seen.length) do
            if (@seen[count].eql?(y)) then
              flag = false
              #finds out which set of answers the current answer is from and increments
              #relevant counter
              assignIndexCounter(y)
            end
            count += 1
          end
          if (flag == true) then
            @seen[cnt] = y
            assignIndexCounter(y)
            cnt += 1
          end
          
          flag = true
        end
        @displayTitle = @displayTitle + "/" + r.poll_title
        @totalVotes = @totalVotes + "." + @numOfVotes.to_s
        @display1 = @display1 + "." + @ans1cnt.to_s
        @display2 = @display2 + "." + @ans2cnt.to_s
        @display3 = @display3 + "." + @ans3cnt.to_s
      end
    end
  end
  erb :profile
end

def assignIndexCounter(y)
  index = @seen.find_index(y)
  if (index == 0) then
    @ans1cnt += 1
  elsif (index == 1)
    @ans2cnt += 1
  elsif (index == 2)
    @ans3cnt += 1
  end
end

def calculate_length_of_account(current_year, current_month, creation_year, creation_month) 
  return (current_year * 12 + current_month) - 
          (creation_year * 12 + creation_month) + 1
end

get "/view_subscriptions" do

  current_user = User.first(user_name: session["user"])
  #Retrieve all purchased stories
  @purchased_stories = Reading.retrieve_stories(session["user"])

  #Get the number of stories bought
  @stories_bought_count = @purchased_stories.length

  erb :view_subscriptions
end

  
get "/wishlist" do
  current_user = User.first(user_name: session["user"])
  #Retrieve all the wishlisted stories
  @wishlisted_stories = Wishlist.retrieve_story(session["user"])

  #Retrieve the wishlisted stories count
  @wishlisted_stories_count = @wishlisted_stories.length
  erb :wishlist
end

get "/liked_stories" do
  @liked_stories = Story.join(:story_likes, liked_story_id: :story_id).where(liker_name: session["user"]).map([:story_id, :title])
  @disliked_stories = Story.join(:story_dislikes, disliked_story_id: :story_id).where(disliker_name: session["user"]).map([:story_id, :title])
  erb :liked_stories
end

