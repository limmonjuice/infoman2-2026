alter table users
add column password varchar(60) not null,
add column date_created timestamp default now();

create table roles(
    id SERIAL primary key,
    name varchar(50) unique not null,
    date_created timestamp default now()
);

create table user_roles(
    id SERIAL primary key,
    user_id bigint not null,
    role_id bigint not null,
    foreign key(user_id) references users(id) on update cascade on delete cascade,
    foreign key(role_id) references roles(id) on update cascade on delete cascade
);