get "/writing" do
  
  @form_was_submitted = !params.empty?
  @submission_error = nil
  @title_error = nil
  @story_content_error = nil
  @price_error = nil

  if session["logged_in"] == false then
    redirect "/login"
  end
  erb :writing

end

post '/sendStory' do

  #gets all the parameters so they are ready to be made into a row
  @title = (params[:title]).strip
  @genre = params.fetch("genres", "").strip
  @cost = (params[:price]).to_i
  @story_content = params.fetch("story_content", "").strip
  @language = params.fetch("language", "").strip
 
  #gets the current user - this will be used for the author
  @user = session["user"]
  user = User.first(user_name: @user)
  @username = user.user_name

  #create a new story in the database
  story = Story.new
  story.title = @title
  story.content = @story_content
  story.cost = @cost
  story.genre = @genre
  story.author = @username
  story.language = @language
  story.save_changes

  redirect "/"

  erb :writing 
end