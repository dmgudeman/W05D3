PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL,
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY(user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  replier_id INTEGER NOT NULL,
  reply_body TEXT NOT NULL,

  
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY(replier_id) REFERENCES users(id)

);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_liked_id INTEGER,
  question_liked_id INTEGER,

  FOREIGN KEY(user_liked_id) REFERENCES users(id),
  FOREIGN KEY(question_liked_id) REFERENCES questions(id)
);

INSERT INTO
  users( fname, lname)
VALUES
  ('David', 'Gudeman'),
  ('Ningxiao', 'Cao'),
  ('Peter', 'Parker'),
  ('Xavier', 'Octopus')
;

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Where is Peter?', 'I have not seen Peter, Has anyone seen him?', 0),
  ('SQL', 'What does SQL stand for?', 1),
  ('ADT', 'What is ADT?', 1)
;




