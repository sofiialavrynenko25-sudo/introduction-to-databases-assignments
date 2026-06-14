create database assignment1;

use assignment1;

create table players 
(
	player_id serial primary key,
	profile_name varchar(255) not null,
	email varchar(255),
	registered_at date not null,
	status varchar(255)
);

create table game_zones
(
	zone_id serial primary key,
	zone_name varchar(255),
	price int not null
);

create table computers
(
	computer_id serial primary key,
	cpu varchar(255),
	zone_id int,
	foreign key (zone_id) references game_zones(zone_id)
);

create table gaming_sessions
(
	session_id serial primary key,
	started_at date not null,
	duration_hours int not null,
	player_id int,
	computer_id int,
	foreign key (player_id) references players(player_id),
	foreign key (computer_id) references computers(computer_id)
);

create table session_game
(
	log_id serial primary key, 
	game_name varchar(255) not null,
	genre varchar(255),
	session_id int,
	foreign key (session_id) references gaming_sessions(session_id)
);

insert into players(profile_name, email, registered_at, status) values
('cyber_knight', 'knight2005@gmail.com', '2025-09-08', 'premium'),
('shadow', 'shadow.warrior@gmail.com', '2025-08-30', 'standard'),
('alexxx', 'alexxxsuper@gmail.com', '2025-07-15', 'standard'),
('hakkaine', 'hakkaineee@gmail.com', '2025-12-25', 'vip'),
('wolf_alpha', 'alpha.new.wolf@gmail.com', '2025-03-27', 'premium'),
('eri_nct', 'eriiicool@gmail.com', '2025-05-18', 'standard'),
('yu__xi', 'yuyuxixi@gmail.com', '2025-01-25', 'vip'),
('aerila_queen', 'aerila.your.queen@gmail.com', '2025-09-09', 'standard'),
('glittcchh', 'iam.glitching@gmail.com', '2025-06-01', 'vip'),
('phoenix', 'phoenix.ultra@gmail.com', '2025-04-05', 'premium');

insert into game_zones(zone_name, price) values
('zone A', 150),
('zone B', 200),
('zone C', 200),
('zone D', 250),
('zone E', 300);

insert into computers(cpu, zone_id) values
('AMD Ryzen 7 7800X3D', 1),
('Intel Core i7-14700K', 1),
('AMD Ryzen 9 7900X', 2),
('AMD Ryzen 7 7800X3D', 2),
('Intel Core i7-14700K', 3),
('AMD Ryzen 7 7800X3D', 3),
('AMD Ryzen 9 7900X', 4),
('Intel Core i7-14700K', 4),
('AMD Ryzen 9 7900X', 5),
('AMD Ryzen 7 7800X3D', 5);

insert into gaming_sessions(started_at, duration_hours, player_id, computer_id) values
('2026-06-14', 2, 1, 10),
('2026-06-13', 1, 2, 9),
('2026-06-14', 3, 3, 8),
('2026-06-12', 2, 4, 7),
('2026-06-13', 4, 5, 6),
('2026-06-13', 3, 6, 5),
('2026-06-14', 2, 7, 4),
('2026-06-14', 4, 8, 3),
('2026-06-10', 3, 9, 2),
('2026-06-13', 1, 10, 1);

insert into session_game(game_name, genre, session_id) values
('The Witcher 1', 'action', 1),
('Minecraft', 'sandbox', 2),
('God of War', 'action', 3),
('Diablo 4', 'action', 4),
('Sims 3', 'simulation', 5),
('Subnautica', 'survival', 6),
('Valorant', 'shooter', 7),
('League of Legends', 'MOBA', 8),
('Dota 2', 'MOBA', 9),
('S.T.A.L.K.E.R.', 'survival', 10);

with club_statistics as 
(
	select 
		play.profile_name,
		game.game_name,
		game.genre,
		game_sess.duration_hours,
		comp.cpu,
		zone.zone_name,
		zone.price,
		(zone.price * game_sess.duration_hours) as total_spent
	from players play
	join gaming_sessions game_sess 
	on play.player_id = game_sess.player_id 
	join computers comp 
	on game_sess.computer_id = comp.computer_id 
	join game_zones zone
	on comp.zone_id = zone.zone_id 
	join session_game game
	on game_sess.session_id = game.session_id 
), 
club_sum_spent as 
(
	select 
		profile_name,
		genre,
		sum(total_spent) as total_spent_sum
	from club_statistics 
	group by profile_name, genre
)
select *
from club_sum_spent
where genre = 'action'
union
select *
from club_sum_spent
where genre = 'MOBA'
union
select *
from club_sum_spent
where genre = 'survival'
order by total_spent_sum desc





