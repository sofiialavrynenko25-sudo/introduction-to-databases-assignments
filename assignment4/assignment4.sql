create table users (
	id serial primary key,
	user_name varchar(255) not null unique,
	email varchar(255),
	created_at date not null check (created_at <= current_date),
	subscription_type varchar(255) not null check (subscription_type in ('standard', 'premium', 'vip'))
);

create table artists (
	id serial primary key,
	artist_name varchar(255) not null unique,
	country varchar(255)
);

create table albums (
	id serial primary key,
	title varchar(255) not null,
	release_date date not null check (release_date <= current_date),
	genre varchar(255),
	artist_id int references artists(id)
);

create table tracks (
	id serial primary key,
	title varchar(255) not null,
	duration int not null check (duration > 0),
	album_id int references albums(id)
);

create table playlists (
	id serial primary key,
	title varchar(255) not null,
	user_id int references users(id)
);

create table playlist_tracks (
	playlist_id int references playlists(id),
	track_id int references tracks(id),
	primary key (playlist_id, track_id)
);

create table user_wallet (
	user_id int primary key references users(id),
	current_balance numeric(10,2) default 0.00 check (current_balance >= 0)
);

create table listen_history (
	id serial primary key,
	user_id int references users(id),
	track_id int references tracks(id),
	listened_at timestamp not null default current_timestamp
);

-- to search who listened what song and when
create index idx_history_user on listen_history(user_id);

-- to search what tracks are in album
create index idx_tracks_album on tracks(album_id);
 
-- to search all albums from the artist
create index idx_albums_artist on albums(artist_id);

-- to search track by title
create index inx_tracks_title on tracks(title);

-- three users
do $$
begin
	if not exists (select 1 from pg_roles where rolname = 'recommendation_creator')
	then create role recommendation_creator login password '123abc@';
	end if;
end
$$;

grant connect on database groovy to recommendation_creator;
grant usage on schema public to recommendation_creator;
grant select on listen_history to recommendation_creator;
grant insert on playlist_tracks to recommendation_creator;

do $$
begin 
	if not exists (select 1 from pg_roles where rolname = 'finance_manager')
	then create role finance_manager login password 'qwe123$';
	end if;
end
$$;

grant connect on database groovy to finance_manager;
grant usage on schema public to finance_manager;
grant select on user_wallet to finance_manager;

do $$
begin 
	if not exists (select 1 from pg_roles where rolname = 'support_manager')
	then create role support_manager login password '567rty#';
	end if;
end
$$;

grant connect on database groovy to support_manager;
grant usage on schema public to support_manager;
grant all privileges on users to support_manager;
grant select on user_wallet to support_manager;

-- one view
create or replace view all_albums_duration as
select
		album.title as album_title,
		album.genre,
		artist.artist_name,
		sum(track.duration) as album_duration
from albums album 
join artists artist on album.artist_id = artist.id
join tracks track on album.id = track.album_id
group by album.id, album.title, album.genre, artist.artist_name
order by album.id asc;

select *
from all_albums_duration;

-- one procedure
create or replace procedure add_track_to_playlist(p_track_id int, p_playlist_id int)
as $$
begin
	if not exists (select 1 from tracks where id = p_track_id)
	then raise exception 'Track does not exist.';
	end if;
	if not exists (select 1 from playlists where id = p_playlist_id)
	then raise exception 'Playlist does not exist.';
	end if;
	insert into playlist_tracks (playlist_id, track_id)
	values (p_playlist_id, p_track_id);
end;
$$ language plpgsql;

call add_track_to_playlist (1, 1);

-- one trigger

create or replace function create_wallet()
returns trigger as $$
begin
	insert into user_wallet(user_id, current_balance)
	values (new.id, 0);
	return null;
end;
$$ language plpgsql;

create trigger create_user_wallet
after insert on users
for each row
execute function create_wallet();