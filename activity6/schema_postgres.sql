CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  first_name varchar(50) NOT NULL,
  last_name varchar(50) NOT NULL,
  email varchar(100) NOT NULL,
  birthdate date NOT NULL,
  added timestamp NOT NULL DEFAULT NOW()
);



CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  author_id INTEGER NOT NULL,
  title varchar(255) NOT NULL,
  description varchar(500) NOT NULL,
  content VARCHAR NOT NULL,
  date date NOT NULL,
  foreign key (author_id) references authors(id) ON DELETE CASCADE
);



