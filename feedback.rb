get "/feedback" do 
  @form_was_submitted = false
  @submission_error = nil
  @story_id = params[:story_id] 
  @referrer = params[:referrer]
  if !@story_id.nil? && Story.first(story_id: @story_id)
    erb :feedback
  else
  #If no valid story is found, redirect to a default page or show an error
    redirect "/"
  end
end

post "/feedback" do 

  @user = session["user"]
  user = User.first(user_name: @user)
  @username = user.user_name

  @story_id = params[:story_id]
  @comment_text = params[:comments]
  @feedback_text = params['feedback']

  if @comment_text.strip.empty? && @feedback_text.strip.empty?
    @submission_error = "Please provide your feedback or comment."
    @referrer = params[:referrer]
    erb :feedback
  else
    # Create a new comment entry if the user left a comment
    comments = Comments.new
    comments.story_id = @story_id
    comments.user_name = @username
    comments.comment_text = @comment_text
    comments.save_changes

    # Redirect to the reading page
    redirect "/reading_page?id=#{@story_id}"
  end
end
    