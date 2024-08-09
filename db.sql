CREATE TABLE users (
  user_name TEXT PRIMARY KEY,
  account_type TEXT,
  password BLOB,
  email TEXT,
  popcorn INTEGER,
  compound FLOAT,
  premium INTEGER,
  iv BLOB,
  salt BLOB,
  creation_date TEXT,
  freepopcorn_date TEXT,
  liked_stories TEXT DEFAULT '',
  creator_code TEXT
);

CREATE TABLE stories (
  story_id INTEGER PRIMARY KEY,
   title TEXT, 
   content BLOB, 
   genre TEXT, 
   author TEXT, 
   cost INTEGER, 
   language TEXT, 
   likes INTEGER DEFAULT 0, 
   dislikes INTEGER DEFAULT 0
);

CREATE TABLE polls (
  id INTEGER PRIMARY KEY,
  title TEXT,
  qa BLOB,
  story INTEGER
);

CREATE TABLE subscriptions (
  subscriber TEXT,
  subscribed_account TEXT, 
  PRIMARY KEY (subscriber, subscribed_account), 
  FOREIGN KEY (subscriber) REFERENCES users(user_name) ON DELETE CASCADE, 
  FOREIGN KEY (subscribed_account) REFERENCES users(user_name) ON DELETE CASCADE
);

CREATE TABLE readings (
  reader TEXT,
  stories_reading TEXT, 
  PRIMARY KEY (reader, stories_reading), 
  FOREIGN KEY (reader) REFERENCES users(user_name) ON DELETE CASCADE,
  FOREIGN KEY (stories_reading) REFERENCES stories(story_id) ON DELETE CASCADE
);


CREATE TABLE story_likes (
  id INTEGER PRIMARY KEY,
  liker_name TEXT,
  liked_story_id INTEGER,
  FOREIGN KEY (liker_name) REFERENCES users(user_name) ON DELETE CASCADE,
  FOREIGN KEY (liked_story_id) REFERENCES stories(story_id) ON DELETE CASCADE
);

CREATE TABLE story_dislikes (
  id INTEGER PRIMARY KEY,
  disliker_name TEXT,
  disliked_story_id INTEGER,
  FOREIGN KEY (disliker_name) REFERENCES users(user_name) ON DELETE CASCADE,
  FOREIGN KEY (disliked_story_id) REFERENCES stories(story_id) ON DELETE CASCADE
);

CREATE TABLE wishlists (
  reader TEXT,
  stories_wishlist TEXT,
  PRIMARY KEY (reader, stories_wishlist),
  FOREIGN KEY (reader) REFERENCES users(user_name) ON DELETE CASCADE,
  FOREIGN KEY (stories_wishlist) REFERENCES stories(story_id) ON DELETE CASCADE
);

CREATE TABLE pollvotes (
  poll INTEGER PRIMARY KEY,
  poll_title TEXT,
  answer BLOB
);

CREATE TABLE bannedusers (
  banned_user TEXT PRIMARY KEY
);

CREATE TABLE competition (
  competition_date TEXT PRIMARY KEY,
  winner TEXT,
  runner_up TEXT
);

CREATE TABLE censored_words (
    id INTEGER PRIMARY KEY,
    word TEXT NOT NULL UNIQUE
);

CREATE TABLE comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  story_id INTEGER,
  user_name TEXT,
  comment_text TEXT,
  FOREIGN KEY (story_id) REFERENCES stories(story_id) ON DELETE CASCADE,
  FOREIGN KEY (user_name) REFERENCES users(user_name) ON DELETE CASCADE
);