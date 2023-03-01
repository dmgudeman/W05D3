PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY(author_id) REFERENCES users(id)
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
  questions(title, body, author_id)
VALUES
  ('Where is Peter?', 'I have not seen Peter, Has anyone seen him?', 1),
  ('SQL', 'What does SQL stand for?', 2),
  ('ADT', 'What is ADT?', 2)
;

INSERT INTO
    question_follows(user_id, question_id)
VALUES  
    (1, 1),
    (2, 1),
    (3, 1),
    (2, 2),
    (4, 3);

INSERT INTO
    replies (question_id, parent_reply_id, replier_id, reply_body)
VALUES
    (1, 1, 2, 'Peter Parker is in the park'),
    (2, NULL, 3, 'Structured Query Language'),
    (3, 2, 1, 'Abstract Data Type');

INSERT INTO
    question_likes (user_liked_id, question_liked_id)
VALUES
    (1, 1),
    (2, 1),
    (4, 1),
    (2, 2),
    (1, 2),
    (4, 3);



