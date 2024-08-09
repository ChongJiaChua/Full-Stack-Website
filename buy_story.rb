post "/buy" do

  story_price = (params[:story_price]).to_i
  story_title = (params[:story_title])

  if session["logged_in"] == true

	  #gets the current user and find the story in the database

	  @user = session["user"]
	  user = User.first(user_name: @user)
    reader = session["user"]
    story_id = session["story_id"]

	  story = Story.first(story_id: story_id)

	  #update the popcorn in the user database of the person buying the story

	  if user.popcorn < story_price
		  @price_error = "Not enough money"
      redirect "/payment"
	  end

	  left_over_popcorn = user.popcorn - story_price
	  user.popcorn = left_over_popcorn
	  user.save_changes

	  #The stories bought is inserted into the table using a foreign key
    
    Reading.insert(reader: reader, stories_reading: story_id)

	  #the author of the story gets the popcorn

	  writer = User.first(user_name: story.author)

	  new_popcorn = writer.popcorn + story_price
	  writer.popcorn = new_popcorn
	  writer.save_changes
    
    redirect "/reading_page?id=#{session["story_id"]}"
    @story = story
    erb :reading_page

  else

    redirect "/login" 

  end

end

post "/set_free_stories" do
	story_id = session["story_id"]
	current_story = Story.first(story_id: story_id)
	post_story_price = 0
	current_story.update(cost: 0)

  redirect "/reading_page?id=#{story_id}"
end

post "/reset_free_stories" do
	story_id = session["story_id"]
	current_story = Story.first(story_id: story_id)
	current_story.update(cost: 20)

	redirect "/reading_page?id=#{story_id}"

end