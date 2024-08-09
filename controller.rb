get "/" do
  @stories = Story.all.shuffle
  today = Date.today
  last_day_of_month = Date.new(today.year, today.month, -1)
 
  # Get the last competition record to find out when it was happened
  last_competition = DB[:competition].order(:competition_date).last
 
 
  @winners = []
  @runner_up = nil
 
  # Only calculate winners at the last day of the month
  if today == last_day_of_month && (last_competition.nil? || Date.parse(last_competition[:competition_date]) < today)
    readers = Reading.top_readers
    if readers.any?
      highest_count = readers.first[:count]

      # Counting how many books each reader has read to determine the winners
      readers.each do |reader|
        user = User.where(user_name: reader[:reader]).first
        if user
          if reader[:count] == highest_count
            username = user.user_name
            count = reader[:count]
            winner_entry = { username: username, count: count }
            @winners << winner_entry
            user.update(popcorn: user.popcorn + 300)  # Popcorn amount for winners
          elsif @runner_up.nil? && reader[:count] < highest_count
            username = user.user_name
            count = reader[:count]
            @runner_up = { username: username, count: count }  # Only one runner-up
            user.update(popcorn: user.popcorn + 100)  # Popcorn amount for the runner-up
          end
        end
      end
    end

    # Prepare winner and runner-up data
    winner_usernames = @winners.map { |winner| winner[:username] }
    winner_usernames_string = winner_usernames.join(", ")
    runner_up_name = @runner_up ? @runner_up[:username] : nil

    # Check for existing competition and insert a new record if none exists
    existing_competition = DB[:competition].where(competition_date: today.to_s).first
    if existing_competition.nil?
      DB[:competition].insert(
        competition_date: today.to_s,
        winner: winner_usernames_string,
        runner_up: runner_up_name
      )
    end
  end

  erb :home
end
 
 
 get "/search" do
  # Retrieve search query and search type from parameters
  @query = params['query']
  session[:query] = @query  # Store search query in session for later use
  @search_type = params['search-type']
   # Initialize variables to store search results
  @story_results = []
  @user_results = []
  @poll_results = []
   # Perform search based on search type
  case @search_type
  when 'stories'
    # Search for stories by title or author
    @story_results = Story.where(Sequel.ilike(:title, "%#{@query}%") | Sequel.ilike(:author, "%#{@query}%"))
  when 'users'
    # Search for users by username (excluding the current user)
    @user_results = User.where(Sequel.ilike(:user_name, "%#{@query}%")).exclude(user_name: session['user'])
  end
   # Render the search results view
  erb :search
 end
 
 
 get "/competition" do
  today = Date.today
  last_day_of_month = Date.new(today.year, today.month, -1)
 
  # Fetch the last competition record to determine when it was last run
  last_competition = DB[:competition].order(:competition_date).last
 
  @winners = []
  @runner_up = nil
 
  # Only calculate winners at the last day of the month
  if today == last_day_of_month && (last_competition.nil? || Date.parse(last_competition[:competition_date]) < today)
    # Proceed with determining the winners and runner-up
    readers = Reading.top_readers
    if readers.any?
      highest_count = readers.first[:count]
  
      # Loop through readers to find winners and runner-up
      readers.each do |reader|
        user = User.where(user_name: reader[:reader]).first
        if user
          if reader[:count] == highest_count
            # Set the winners entry
            username = user.user_name
            count = reader[:count]
            winner_entry = { username: username, count: count }
            @winners << winner_entry
          elsif @runner_up.nil? && reader[:count] < highest_count
            # Set the runner-up entry
            username = user.user_name
            count = reader[:count]
            @runner_up = { username: username, count: count }
          end
        end
      end
  
      # Insert the competition record into the database
      DB[:competition].insert(
        competition_date: today.to_s,
        winner: @winners.map { |w| w[:username] }.join(", "),
        runner_up: @runner_up ? @runner_up[:username] : nil
      )
    end
  else
    # Retrieve winners and runner-up usernames from the last competition
    if last_competition
      winner_usernames = last_competition[:winner].split(", ")
  
      @winners = winner_usernames.map do |username|
        count = Reading.where(reader: username).count
        { username: username, count: count }
      end
  
      if last_competition[:runner_up]
        runner_up_username = last_competition[:runner_up]
        runner_up_count = Reading.where(reader: runner_up_username).count
        @runner_up = { username: runner_up_username, count: runner_up_count }
      end
    end
  end
  erb :competition
end
 
 
 
 
 get "/logout" do
  session.clear
  redirect "/"
 end
 