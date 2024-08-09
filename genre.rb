get '/genre_search' do
  @stories = Story.all.shuffle
  erb :genre_search
end

get '/genre' do
  @genre = params[:name]
  @language = params[:language]
  # Fetch stories based on the selected genre from the database
  @genre_results = Story.where(Sequel.ilike(:genre, "%#{@genre}%"))
                  .where(Sequel.ilike(:language, "%#{@language}%"))
                  .all.shuffle
  @genre_results_exist = !@genre_results.empty?
  erb :genre
end