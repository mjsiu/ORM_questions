DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname varchar(255) NOT NULL,
  lname varchar(255) NOT NULL
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Mack', 'Siu'),
  ('Christine', 'Liao');

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title varchar(255) NOT NULL,
  body varchar(255) NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('how?', 'how do you cook?', (SELECT id FROM users WHERE fname = 'Mack')),
  ('abz?', 'asdasdsada?', (SELECT id FROM users WHERE fname = 'Mack')),
  ('class?', 'what time is class', (SELECT id FROM users WHERE fname = 'Mack')),
  ('why?', 'why is the sky blue?', (SELECT id FROM users WHERE fname = 'Christine')),
  ('when?', 'why is the sky blue?', (SELECT id FROM users WHERE fname = 'Christine')),
  ('which?', 'why is the sky blue?', (SELECT id FROM users WHERE fname = 'Mack')),
  ('please?', 'why is the sky blue?', (SELECT id FROM users WHERE fname = 'Christine')),
  ('where?', 'why is the sky blue?', (SELECT id FROM users WHERE fname = 'Christine'));


DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES question(id)

);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Mack'), (SELECT id FROM questions WHERE title = 'how?')),
  ((SELECT id FROM users WHERE fname = 'Mack'), (SELECT id FROM questions WHERE title = 'why?')),
  ((SELECT id FROM users WHERE fname = 'Christine'), (SELECT id FROM questions WHERE title = 'when?')),
  ((SELECT id FROM users WHERE fname = 'Christine'), (SELECT id FROM questions WHERE title = 'which?')),
  ((SELECT id FROM users WHERE fname = 'Christine'), (SELECT id FROM questions WHERE title = 'please?')),
  ((SELECT id FROM users WHERE fname = 'Mack'), (SELECT id FROM questions WHERE title = 'when?')),
  ((SELECT id FROM users WHERE fname = 'Mack'), (SELECT id FROM questions WHERE title = 'which?')),
  ((SELECT id FROM users WHERE fname = 'Mack'), (SELECT id FROM questions WHERE title = 'please?'));

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body varchar(255) NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

INSERT INTO
  replies(question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'why?'), NULL, (SELECT id FROM users WHERE fname = 'Christine'), 'What a good idea!');

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  number_likes INTEGER,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  question_likes(number_likes, question_id, user_id)
VALUES
  (4, (SELECT id FROM questions WHERE title = 'how?'), (SELECT id FROM users WHERE fname = 'Mack')),
    (4, (SELECT id FROM questions WHERE title = 'how?'), (SELECT id FROM users WHERE fname = 'Mack')),
  (4, (SELECT id FROM questions WHERE title = 'how?'), (SELECT id FROM users WHERE fname = 'Christine'));
