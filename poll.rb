get "/createpoll" do
  $notAuthorError
  erb :createpoll
end

get "/pollcreated" do
  erb :pollcreated
end

get "/poll" do
  @error = ""
  erb :poll
  
end

get "/viewpoll" do
  $poll_to_view = Poll.first(id: session["pollId"])
  erb :viewpoll
end

def createpoll(poll_row, id,title, data, story)
  poll_row.id = id.to_i
  poll_row.title = title
  poll_row.qa = data
  poll_row.story = story
  poll_row.save_changes
end

post "/createpoll" do
  @title = params.fetch("title").strip
  @story_id = params.fetch("story").strip
  split = @story_id.split(":")
  @story_id = split[0]
  if (Story.first(story_id: @story_id) != nil && (Story.first(story_id: @story_id)).author != session["user"]) then
    $notAuthorError = "Sorry, you are not the author. Poll has not been created."
    redirect "/createpoll"
  end
  @id
  if Poll.all.empty? then
    @id = 0
  else
    #order by id, limit 1 - returns the highest id number
    array = DB.execute("select * from polls order by id desc limit 1").to_a
    @id = (array[0][0].to_i + 1)
  end

  #Answer code format a[ans number][question number]
  @q1 = params.fetch("q1","null").strip
  @a11 = params.fetch("a11","null").strip
  @a21 = params.fetch("a21","null").strip
  @a31 = params.fetch("a31","null").strip

  @q2 = params.fetch("q2","null").strip
  @a12 = params.fetch("a12","null").strip
  @a22 = params.fetch("a22","null").strip
  @a32 = params.fetch("a32","null").strip

  @q3 = params.fetch("q3","null").strip
  @a13 = params.fetch("a13","null").strip
  @a23 = params.fetch("a23","null").strip
  @a33 = params.fetch("a33","null").strip
  @poll = Poll.new();
  #/ = end of question
  #. end of answer to question
  questionList = @q1 + "/" + @a11 + " " + @a21 + " " + @a31 + "." + 
  @q2 + "/" + @a12 + " " + @a22 + " " + @a32 + "." + @q3 + "/" +
  @a13 + " " + @a23 + " " + @a33
  createpoll(@poll, @id, @title, Sequel.blob(questionList), @story_id)
  erb :pollcreated
end

post "/poll" do
  
  #display polls, filtered by story?
  #poll table needs acciated story id
  #text of answers
  @story_title = params.fetch("storytitle").strip
  stories = Story.where(Sequel.ilike(:title, "%#{@story_title}%"))
  @polls = []
  if (!stories.empty?) then
    stories.each do |s| 
      poll = Poll.where(story: s.story_id).to_a
      if (!poll.empty?) then
        @polls += poll
      end
    end
  end
  if (!@polls.empty?) then
    erb :poll
  else
    @error = "Sorry, no polls have been created for that story"
    erb :poll
    
  end
end

post "/answerpoll" do
  ans1 = params.fetch("0","").strip
  ans2 = params.fetch("1","").strip
  ans3 = params.fetch("2","").strip
  if (Pollvote.first(poll: $poll_to_view.id) == nil) then
    poll_ans = Pollvote.new()
    poll_ans.poll = $poll_to_view.id
    poll_ans.poll_title = $poll_to_view.title
    poll_ans.answer = ans1 + " " + ans2 + " " + ans3 + " "
    poll_ans.save_changes
  else
    poll_ans = Pollvote.first(poll: $poll_to_view.id.to_s)
    poll_ans.answer = poll_ans.answer + ans1 + " " + ans2 + " " + ans3 + " "
    poll_ans.save_changes
  end
  @voted = "Vote Submitted"
  erb :viewpoll

end