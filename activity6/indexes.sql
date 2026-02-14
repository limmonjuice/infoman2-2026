create index idx_posts_title_datedesc on posts (title, date desc);

create index idx_posts_title on posts (title);

create index idx_posts_date on posts (date);