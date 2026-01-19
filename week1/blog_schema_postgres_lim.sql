-- Original MySQL Schema
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Data for the tables
INSERT INTO users (username) VALUES 
('alice'), ('bob'), ('ally'), ('tyrrone'), ('ashley'), ('lee'), ('gail');

INSERT INTO posts (user_id, title, body) VALUES
(1, 'First Post!', 'This is the body of the first post.'),
(2, 'Bob''s Thoughts', 'A penny for my thoughts.'),
(3, 'Makeup Tutorial', 'Get ready with me!.'),
(4, 'Python Things', 'How can I do typecasting'),
(5, 'Mangga Mukbang', 'Ang sarap ng suka beh.'),
(6, 'Torogan House', 'Feast your eyes on my beautiful poster.'),
(7, 'Architectural Journey', 'Study with me!.');

INSERT INTO comments (post_id, user_id, comment) VALUES
(1, 2, 'Great first post, Alice!'),
(2, 1, 'Interesting thoughts, Bob.'),
(6, 5, 'Wow! pinagawa lang yan e!'),
(7, 3, 'Sana makagradute ka on time, twin!.'),
(5, 4, 'Tasty! I am craving rn!'),
(3, 7, 'So ganda naman nyan, twin!.'),
(4, 6, 'Use AI bro');