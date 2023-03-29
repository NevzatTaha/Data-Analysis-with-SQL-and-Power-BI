/*Data Cleaning*/
select*from simpsons_characters;
select*from simpsons_episodes;
select*from simpsons_rt_scores;

-- I wil drop gender column in simpsons_characters because it is redundant. 

alter table simpsons_characters drop column gender; 

select count(name) as null_count_for_name,count(normalized_name)as null_count_for_normalized_name
from simpsons_characters where name  is null 
or normalized_name is null;

-- There is no null values.

---------------------------

-- First row is headline of the table, so I will drop it, and  I will change columns type
delete from simpsons_episodes where title='title';


alter table simpsons_episodes
alter column id type integer using id::integer,
alter column original_air_date type date using original_air_date::date,
alter column season type integer using season::integer,
alter column number_in_season type integer using number_in_season::integer,
alter column number_in_series type integer using number_in_series::integer,
alter column imdb_rating type numeric USING imdb_rating::numeric ;


-- -- Us_viewers_in_millions has tbd data. That means it is not available data yet. Hence, 
-- I will replace them with an appropriate way. Also, if there is null values, they also has to be changed.


select *from simpsons_episodes where 'title 'is null or
description is null or
original_air_date is null or
production is null or
directed_by is null or
written_by is null or
season is null or 
number_in_season is null or 
number_in_series is null or 
us_viewers_in_millions is null or 
imdb_rating is null
;
-- -- There are common data which include TBD and null values for different columns.
-- However, They are few, so I will basically drop them.


delete from simpsons_episodes where us_viewers_in_millions ='TBD' and imdb_rating  is null;

-- I will check whether there is a non numeric value or not. 
select*from simpsons_episodes where us_viewers_in_millions ~*'^[a-z]'

-- N/A values are 12.2, 14.4 and 13.25 orderly.
-- YOU CAN CHECK SOURCES THAT I TAKE 'HTTPS://EN.WIKIPEDIA.ORG/WIKI/LIST_OF_THE_SIMPSONS_EPISODES_(SEASONS_1–20)#SEASON_8_(1996–97)'

UPDATE simpsons_episodes 
SET us_viewers_in_millions= 12.2 
WHERE id = 159;

UPDATE simpsons_episodes 
SET us_viewers_in_millions= 14.4 
WHERE id = 160;

UPDATE simpsons_episodes 
SET us_viewers_in_millions= 13.25 
WHERE id = 172;

-- Now, I will update us_viewers_in_millions as a numeric. 

alter table simpsons_episodes alter column us_viewers_in_millions type numeric USING us_viewers_in_millions::numeric;








-- Also, I will update two columns with upper case because although some words are same, it may seem different.

update simpsons_episodes set directed_by=upper(directed_by), written_by=upper(written_by);

----------------------

SELECT 
  (SELECT COUNT(*) FROM simpsons_rt_scores WHERE rt_critic_score IS NULL) AS numbernull_rt_critic,
  (SELECT COUNT(*) FROM simpsons_rt_scores WHERE rt_user_score IS NULL ) AS numbernull_rt_user,
  (SELECT COUNT(*) FROM simpsons_rt_scores WHERE rt_critic_count IS NULL ) AS numbernull_rt_cr_count,
  (SELECT COUNT(*) FROM simpsons_rt_scores WHERE rt_user_count IS NULL ) AS numbernull_rt_user_count
FROM simpsons_rt_scores
LIMIT 1;

-- There are many null values in rt_critic_score, but Rottentomatoes website does not also include values.
-- Hence, I will fill it with average.
select avg(rt_critic_score) from simpsons_rt_scores;

update simpsons_rt_scores set rt_critic_score= replace(rt_critic_score, '%','');

alter table simpsons_rt_scores alter column rt_critic_score type numeric using rt_critic_score::numeric;


update simpsons_rt_scores set rt_critic_score=(select  avg(rt_critic_score) from simpsons_rt_scores)
where rt_critic_score is null;

/*Data Reshaping*/

-- I will create  year, month and day columns from original_air_date.

alter table simpsons_episodes add column day numeric,add column month numeric, add column year numeric;

update simpsons_episodes set year = (select extract(year from original_air_date)) where year is null;

update simpsons_episodes set month = (select extract(month from original_air_date)) where month is null;

update simpsons_episodes set day = (select extract(day from original_air_date)) where day is null;



---------------------
-- lets convert rt_user_score to numeric values.

update simpsons_rt_scores set rt_user_score= replace(rt_user_score, '%','');

alter table simpsons_rt_scores alter column  rt_user_score type numeric using  rt_user_score::numeric;

-- I have finished all data reshaping and data  cleaning. Now, It is time to explore. 


/* Exploratary Data Analysis*/ 

select* from simpsons_characters order by id asc;

-- Lets find how many charecters have simpson last name

select*from simpsons_characters where normalized_name like '%simpson' order by id asc;

-- There are fourteen charecter whose last name are simpson.

---------
-- 1) which episodes reached the highest IMDb rating and viewers. ?
-- 2) Which season reached the highest average IMDb rating and viewers?
-- 3) which months movie has reached the highest number of viewers and IMDb rating?
-- 4) On which days did the movie reach the highest number of viewers and IMDb rating?
-- 5) Which writer and director reached the highest IMDb rating and viewers?
-- 6) According to rotten tomatoes, which season is the most successful, and whether there are differences between IMDb and rotten tomatoes?
select*from simpsons_characters;
select*from simpsons_episodes;
select*from simpsons_rt_scores;

--1)

select title,season,number_in_season, us_viewers_in_millions,imdb_rating from simpsons_episodes
order by us_viewers_in_millions desc,imdb_rating desc limit 10;

select title,season,number_in_season, us_viewers_in_millions,imdb_rating from simpsons_episodes
order by imdb_rating desc ,us_viewers_in_millions desc limit 20;

-- Season 2 episode 1 is the one which reached highest number of viewers, while season 8 episodes 23 have highest imdb rating.

--2)
select season,round(avg( us_viewers_in_millions)) as us_viewers_in_millions_average ,avg(imdb_rating)as imdb_rating_average from simpsons_episodes
group by season order by us_viewers_in_millions_average desc,imdb_rating_average desc ;

-- The season 1 has been watched around 28 million times which is the higher than other seasons by US viewers.

select season,round(avg( us_viewers_in_millions)) as us_viewers_in_millions_average ,avg(imdb_rating)as imdb_rating_average from simpsons_episodes
group by season order by imdb_rating_average desc ;

-- The season 7 has the highest imdb rating in seasons.

--3)
select month, round(avg(us_viewers_in_millions)) as us_viewers_in_millions_average  ,avg(imdb_rating)as imdb_rating_average  from simpsons_episodes
group by month order by us_viewers_in_millions_average desc,imdb_rating_average desc;

select month, round(avg(us_viewers_in_millions)) as us_viewers_in_millions_average  ,avg(imdb_rating)as imdb_rating_average  from simpsons_episodes
group by month order by  imdb_rating_average desc;

-- People watched around 17 million times 7. month. Similarly, episodes that has been published in 7. month have one of the highest imdb average.

--4) This is a similar with third question. For the better analyse, I will convert days to string format, such as Monday Tuesday.


alter table simpsons_episodes alter column day type text;

UPDATE simpsons_episodes 
SET day = to_char(original_air_date,'Dy');

select day,avg(us_viewers_in_millions) as average_viewers,
avg(imdb_rating) as average_imdb,count(id) as count_published
from simpsons_episodes 
group by day order by average_viewers desc;

-- The movie has published mostly  on sunday, but there are huge differences between other days. Tuesday, Wednesday and Friday may not take into account
-- because movie published few days on these days. However, episodes which was published on Thursday should take into account. 


--5)
select 	directed_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by directed_by order by contribution desc;

-- Mark is  a director who reached highest contribution with 83.

select 	directed_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by directed_by order by average_imdb desc,average_viewer desc;

select 	directed_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by directed_by order by average_viewer desc, average_imdb desc;



-- Mostly,  director who reached highest average imdb and viewers have few contribution, 
-- so I will get director who directed more than once. 

select 	directed_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by directed_by 
having count(id) > 1 order by average_imdb desc;

-- Jeffrey Lync had highest imdb average by directing 7 movies.


select 	directed_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by directed_by 
having count(id) > 1 order by average_viewer desc;

-- Rich Moore had highest average view with 15 episodes.

What about writer?

select 	written_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by written_by
having count(id) > 1 order by contribution desc;

-- "JOHN SWARTZWELDER" is the writer of many episodes, 53 episodes.


select 	written_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by written_by
having count(id) > 1 order by average_imdb desc,average_viewer desc;

-- Dan Mcgrath has the highest average imdb rating in two episodes.

select 	written_by,
avg(imdb_rating) as average_imdb,
avg(us_viewers_in_millions) as average_viewer,
count(id) as contribution
from simpsons_episodes group by written_by
having count(id) > 1 order by average_viewer desc;

-- Ken Levine & David Isaacs have highest average view with about 25.4 million in two episodes.


-- 6) I will take rt_critic_score and rt_user_score average for the estimate best season. 

select season, (rt_critic_score + rt_user_score)/2 as rt_score_Average from simpsons_rt_scores order by  rt_score_Average desc ;

-- so season 6 and 8 is the most succesfull one for rotten tomatoes while imdb asserts season 7 is better.