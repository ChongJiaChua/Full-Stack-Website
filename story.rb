
get '/write' do
end

post '/submit_story' do
end

get '/reading_page' do
  # Retrieve the story ID from the query parameters
  story_id = params['id']
  session["story_id"] = story_id
  @is_subscribed = !Reading[reader: session["user"], stories_reading: session["story_id"]].nil?
  @writer_story = true if Story.first(story_id: story_id).author == session["user"]
  session["initial_cost"] = Story.first(story_id: story_id).cost
  # Attempt to find the corresponding story in the database
  @story = Story.first(story_id: story_id)
  @comments = DB[:comments]
               .where(story_id: story_id)
               .select(:user_name, :comment_text)
               .all
  current_user = User.first(user_name: session["user"])
  @is_management = true if !current_user.nil? && current_user.account_type == "management"
  @is_admin = true if  !current_user.nil? && current_user.account_type == "admin"
  @is_free = true if Story.first(story_id: story_id).cost == 0
  @is_liked = !StoryLike.where(liker_name: session[:user], liked_story_id: @story.story_id).empty?
  @is_disliked = !StoryDislike.where(disliker_name: session[:user], disliked_story_id: @story.story_id).empty?
  @likes_count = @story.likes
  @dislikes_count = @story.dislikes
  @is_added = !Wishlist[reader: session["user"], stories_wishlist: session["story_id"]].nil?
  if @story
    # Render the 'reading_page.erb' template with the story details
    erb :reading_page
  else
    # Handle case where story is not found (e.g., display an error message)
    erb :reading_page  
  end
end

post "/add_to_wishlist" do
  user = User.first(user_name: session["user"])
  reader = session["user"]
  story_id = session["story_id"]
  if session["logged_in"]

    Wishlist.insert(reader: reader, stories_wishlist: story_id)
    redirect "/reading_page?id=#{session["story_id"]}"
  else
    redirect '/login'
  end

end

post "/remove_from_wishlist" do
  Wishlist.where(reader: session["user"], stories_wishlist: session["story_id"]).delete

  redirect "/reading_page?id=#{session["story_id"]}"
end

  
post "/reading_page" do
  if session["logged_in"] == true
    story_id = params['story_id']
    current_user = session[:user]
    
    @story = Story.first(story_id: story_id)
    @is_liked = !StoryLike.where(liker_name: session[:user], liked_story_id: @story.story_id).empty?
    @is_disliked = !StoryDislike.where(disliker_name: session[:user], disliked_story_id: @story.story_id).empty?
    action = params['action']
  
    if action == "like"
      if @is_disliked
        # If the user has previously disliked the story, remove the dislike
        StoryDislike.where(disliker_name: session[:user], disliked_story_id: story_id).delete
        # Decrement the dislike count for the story
        @story.update(dislikes: [@story.dislikes - 1, 0].max)
      end
  
      if !@is_liked
        # If the user has not liked the story, add a like
        StoryLike.create(liker_name: session[:user], liked_story_id: story_id)
        # Increment the like count for the story
        @story.update(likes: @story.likes + 1)
      end
    elsif action == "unlike"
      if @is_liked
        # If the user has previously liked the story, remove the like
        StoryLike.where(liker_name: session[:user], liked_story_id: story_id).delete
        # Decrement the like count for the story
        @story.update(likes: [@story.likes - 1, 0].max)
      end
    elsif action == "dislike"
      if @is_liked
        # If the user has previously liked the story, remove the like
        StoryLike.where(liker_name: session[:user], liked_story_id: story_id).delete
        # Decrement the like count for the story
        @story.update(likes: [@story.likes - 1, 0].max)
      end
  
      if !@is_disliked
        # If the user has not disliked the story, add a dislike
        StoryDislike.create(disliker_name: session[:user], disliked_story_id: story_id)
        # Increment the dislike count for the story
        @story.update(dislikes: @story.dislikes + 1)
      end
    elsif action == "undislike"
      if @is_disliked
        # If the user has previously disliked the story, remove the dislike
        StoryDislike.where(disliker_name: session[:user], disliked_story_id: story_id).delete
        # Decrement the dislike count for the story
        @story.update(dislikes: [@story.dislikes - 1, 0].max)
      end
    end
  
    redirect "/reading_page?id=#{session["story_id"]}"
  else
    redirect "/login"
  end


end

post "/report" do 
  erb :contact
end

post "/delete_story" do
  story_id = session["story_id"]
  Reading.where(stories_reading: story_id).delete
  Wishlist.where(stories_wishlist: story_id).delete
  Story.where(story_id: story_id).delete

  redirect "/"
end

post "/filter_censor_words" do
  word_to_filter = params[:word]
  CensoredWords.create(word: word_to_filter)
  redirect "/reading_page?id=#{session["story_id"]}"

end

post "/feedback" do
  erb :feedback
end