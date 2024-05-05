-- DBMS-2 PROJECT Pie-in-the-Sky (IPL Match Bidding App)

-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
-- solution:
with bidder_percent as 
(select bid_pts.bidder_id,bidder_name, no_of_bids, bid_status
from ipl_bidder_points bid_pts join ipl_bidding_details bidd_dt
on bid_pts.bidder_id = bidd_dt.bidder_id join ipl_bidder_details bdr_dt
on bdr_dt.bidder_id = bid_pts.bidder_id
where bid_status = 'won'),
bidder_percent_1 as
(select bidder_id,bidder_name,no_of_bids,count(bid_status)as wins
from bidder_percent
group by bidder_id,bidder_name,no_of_bids)
select bidder_id,bidder_name as `Bidder Name`,round(((wins)/(no_of_bids))*100,2) as `Win(%)`
from bidder_percent_1
order by `Win(%)` desc;

-- Megaduta Dheer  has the maximum win % , since he has 100% win he won all the bids which he made


-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.
-- solution:
select stadium_name,city,count(match_id) as Matches_Played
from ipl_stadium std join ipl_match_schedule mt_sch
on std.stadium_id = mt_sch.stadium_id
group by stadium_name,city
order by Matches_Played desc;

-- Most number of matches played in Wankhede Stadium

-- 3.	In a given stadium, what is the percentage of wins by a team that has won the toss?
-- solution: 
with toss_match_win as 
(select std.stadium_name,count(mtch.match_id) as Wins
from ipl_match mtch join ipl_match_schedule mt_sch
on mtch.match_id = mt_sch.match_id join ipl_stadium std 
on std.stadium_id = mt_sch.stadium_id
where toss_winner = match_winner
group by std.stadium_name),
matches as
(select std.stadium_name,count(match_id) as Total_matches
from ipl_stadium std join ipl_match_schedule mt_sch
on std.stadium_id = mt_sch.stadium_id
group by std.stadium_name)
select t.stadium_name, round((wins/total_matches)*100,2) as `Win(%) of team won the toss`
from toss_match_win t join matches m 
on t.stadium_name = m.stadium_name
order by `Win(%) of team won the toss` desc;
 
-- 'Sawai Mansingh Stadium' has highest win % of team won the toss

-- 4.	Show the total bids along with the bid team and team name.
-- solution:
select Bid_team, team_name, count(bidder_id) as Total_bids
from ipl_bidding_details bidd_dt join ipl_team te on
te.team_id = bidd_dt.bid_team
where bid_status <> 'cancelled'
group by Bid_team, team_name 
order by Total_bids desc;

-- Sunrisers Hyderabad has most no of bids  

-- 5.	Show the team ID who won the match as per the win details.
-- solution;
with win_detail as
(select *,
case
	when win_details like 'Team csk%' then 'CSK'
    when win_details like 'Team mi%' then 'MI'
    when win_details like 'Team dd%' then 'DD'
    when win_details like 'Team kxip%' then 'KXIP'
    when win_details like 'Team rr%' then 'RR'
    when win_details like 'Team kkr%' then 'KKR'
    when win_details like 'Team rcb%' then 'RCB'
    when win_details like 'Team srh%' then 'SRH'
end as winning_team
from ipl_match)
select Team_id,Team_name,win_details
from win_detail wd join ipl_team te 
on wd.winning_team = te.remarks;


-- 6.	Display the total matches played, total matches won and total matches lost by the team along with its team name.
-- solution:
with team_stats as
(select tes.team_id,team_name,matches_played,matches_won, matches_lost
from ipl_team_standings tes join ipl_team te 
on tes.team_id = te.team_id)
select team_id,team_name,sum(matches_played) as Total_played, sum(matches_won)as Total_wins, sum(matches_lost) as Total_lost
from team_stats
group by team_id,team_name;


-- 7.	Display the bowlers for the Mumbai Indians team.
-- solution:
select player.player_id, player_name,player_role,team_name
from ipl_team_players tepl join ipl_player player 
on player.player_id = tepl.player_id join ipl_team te 
on tepl.team_id = te.team_id
where player_role = 'bowler' and te.remarks = 'MI';

-- Total players in MI
select player.player_id, player_name,player_role,team_name
from ipl_team_players tepl join ipl_player player 
on player.player_id = tepl.player_id join ipl_team te 
on tepl.team_id = te.team_id
where te.remarks = 'MI';

-- There are totally 9 bowlers out of 15 players in Mumbai Indians 

-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
-- solution:
with all_rounders as
(select player.player_id, player_name,player_role,team_name
from ipl_team_players tepl join ipl_player player 
on player.player_id = tepl.player_id join ipl_team te 
on tepl.team_id = te.team_id
where player_role = 'all-rounder')
select Team_name, count(player_id) as Total_all_rounders
from all_rounders
group by team_name
having total_all_rounders > 4
order by total_all_rounders desc;

-- Delhi and Punjab has maximum number of all-rounders


-- 9.	 Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium bidding year-wise.
--  Note the total bidders’ points in descending order and the year is the bidding year.
--       Display columns: bidding status, bid date as year, total bidder’s points
-- solution:
with bidder_points as
(select bid_pt.bidder_id, total_points,date(bid_date) as date, bid_status
from ipl_bidder_points bid_pt join ipl_bidding_details bid_dt 
on bid_pt.bidder_id = bid_dt.bidder_id join ipl_team te
on bid_dt.bid_team = te.team_id join ipl_match_schedule mtch_sch
on bid_dt. schedule_id = mtch_sch.schedule_id join ipl_stadium std 
on std.stadium_id = mtch_sch.stadium_id join ipl_match mtch 
on mtch.match_id = mtch_sch.match_id
where te.remarks = 'csk' and stadium_name = 'M. Chinnaswamy Stadium' and win_details like '%team csk%')
select Bid_status, year(date) as Year, Total_points
from bidder_points
order by total_points desc;

-- Bidder's points who bids on CSK and they won the Match in Chinnaswamy stadium in 2017 is 17 points


-- 10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
-- Note 
-- 1. Use the performance_dtls column from ipl_player to get the total number of wickets
--  2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3.	Do not use joins in any cases.
-- 4.	Display the following columns teamn_name, player_name, and player_role.
-- solution:
with cte_1 as
(select
(select Team_Name
from ipl_team te
where team_id in
(select team_id
from ipl_team_players
where player_id = temp_1.player_id)) as TEAM_NAME,
player_name as PLAYER_NAME, 
(select player_role
from ipl_team_players
where player_id = temp_1.player_id) as PLAYER_ROLE,
Total_Wickets as TOTAL_WICKETS,dense_rank()over(order by total_wickets desc) as Ranking
from(select player_id,player_name, cast(substring(performance_dtls,instr(performance_dtls,'wkt')+4,2) as unsigned int) as Total_wickets
from ipl_player
where player_id in 
(select player_id
from ipl_team_players
where player_role in ('Bowler', 'All-Rounder'))) as temp_1)
select *
from cte_1 
where ranking <=5;

-- Andrew Tye is the leading wicket taker


-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
-- solution:
with cte as
(select *,
case
	when toss_winner = 1 then team_id1
    else team_id2
end as Toss_winning_Team
from ipl_match mtch ),
cte1 as
(select bidder_id,bidd_dt.schedule_id,mtch_sch.match_id,bid_team, toss_winning_team,
case 
	when bid_team = toss_winning_team then 1 
    else 0
end as Win_Loss
from ipl_bidding_details bidd_dt join ipl_match_schedule mtch_sch
on bidd_dt.schedule_id = mtch_sch.schedule_id  join cte 
on mtch_sch.match_id = cte.match_id)
select Bidder_id, (sum(win_loss)/count(bid_team))*100 as `Toss_Win(%)`
from cte1
group by bidder_id
order by `Toss_Win(%)` desc;

-- 12.	find the IPL season which has a duration and max duration.
-- Output columns should be like the below:
--  Tournment_ID, Tourment_name, Duration column, Duration
-- solution:
with cte as
(select *,datediff( date(to_date),date(from_date)) as `Duration(days)`,dense_rank()over(order by datediff( date(to_date),date(from_date)) desc) as drnk
from ipl_tournament)
select TOURNMT_ID,TOURNMT_NAME, `Duration(days)`, `Duration(days)` as `MAX_DURATION(Days)`
from cte
where drnk = 1;
-- There are two IPL seasons have same maximum duration (53 days) which are season 12 and season 13


-- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order 
-- and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
-- Only use joins for the above query queries.
-- Solution:
select distinct bid_dt.Bidder_id,Bidder_name,year(bid_date) as Year, month(bid_date) as Month,
sum(round((case 
	when bid_status = 'won' then 1 
    else 0
end)/(no_of_bids)*total_points,2)) over(partition by bid_dt.bidder_id,year(bid_date),month(bid_date)) as Points_in_2017
from ipl_bidder_details bid_dt join ipl_bidder_points bid_pt
on bid_dt.bidder_id = bid_pt.bidder_id join ipl_bidding_details bidd_dt 
on bidd_dt.bidder_id = bid_pt.bidder_id
where year(bid_date) = 2017
order by Month, Points_in_2017 desc;


-- 14.	Write a query for the above question using sub-queries by having the same constraints as the above question.
-- Solution:
select distinct *
from(select bid_dt.Bidder_id,Bidder_name,year(bid_date) as Year, month(bid_date) as Month,
sum(round((case 
	when bid_status = 'won' then 1 
    else 0
end)/(no_of_bids)*total_points,2)) over(partition by bid_dt.bidder_id,year(bid_date),month(bid_date)) as Points_in_2017
from ipl_bidder_details bid_dt join ipl_bidder_points bid_pt
on bid_dt.bidder_id = bid_pt.bidder_id join ipl_bidding_details bidd_dt 
on bidd_dt.bidder_id = bid_pt.bidder_id
where year(bid_date) = 2017) as t1
order by Month, Points_in_2017 desc;


-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:
-- like Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder
-- solution:
with cte as
(select distinct bid_pt.bidder_id, bidder_name,total_points,no_of_bids,year(bid_date),sum(round((case 
	when bid_status = 'won' then 1 
    else 0
end)/(no_of_bids)*total_points,2)) over(partition by bid_pt.bidder_id,year(bid_date)) as 2018_points
from ipl_bidder_points bid_pt join ipl_bidding_details bid_dt
on bid_pt.bidder_id = bid_dt.bidder_id join ipl_bidder_details bidd_dt 
on bidd_dt.Bidder_id =bid_pt.bidder_id
where year(bid_date) = 2018),
cte1 as
(select Bidder_id, Bidder_name,2018_points,row_number()over(order by 2018_points desc) as Top_3_bidders
from cte),
cte2 as
(select  Bidder_id, Bidder_name,2018_points,row_number()over(order by 2018_points ) as Bottom_3_bidders
from cte)
select c1.Bidder_id,c1.`2018_points`, c1.Bidder_name as Highest_3_bidders, c2.Bidder_id,c2.`2018_points`,c2.Bidder_name as Lowest_3_bidders
from cte1 c1 left join cte2 c2 
on c1.top_3_Bidders = c2.bottom_3_bidders
where top_3_bidders <=3 and bottom_3_bidders <=3;


/*- 16.	Create two tables called Student_details and Student_details_backup. (Additional Question - Self Study is required)

Table 1: Attributes 		Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.
Feel free to add more columns the above one is just an example schema.
Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students in the Student details table. 
Every time the students change their details like their mobile number, You need to update their details in the student details table.  
Here is one thing you should ensure whenever the new students
' details come, you should also store them in the Student backup table so that if you modify the details in the student details table, you will be having the old details safely.
You need not insert the records separately into both tables rather Create a trigger in such a way that It should insert the details into the Student back table when you insert the student details into the student table automatically.*/
-- Solution: 
-- STEP 1: Table1 and Table2 
create table Student_details
( Student_id int,
Student_Name varchar(15),
mail_id varchar(25),
mobile_no int);

create table Student_details_Backup
(operation varchar(20), 
operation_time timestamp,
Student_id int ,
Student_Name varchar(15),
mail_id varchar(25),
mobile_no bigint);

-- STEP 2: creating triggers for insert and update
delimiter %%
create trigger backup_insert 
after insert on student_details
for each row
begin
	insert into student_details_backup(Operation,operation_time,student_id,student_name,mail_id,mobile_no)
	values('Insert',now(),new.student_id,new.student_name,new.mail_id,new.mobile_no);
end %%
delimiter ;

delimiter %%
create trigger backup_update 
after update on student_details
for each row
begin
	insert into student_details_backup(Operation,operation_time,student_id,student_name,mail_id,mobile_no)
	values('Update',now(),new.student_id,new.student_name,new.mail_id,new.mobile_no);
end %%
delimiter ;

-- STEP 3: Inserting values in Table 1 and check table 2 also whether the record is inserted 
insert into student_details(student_id,student_name,mail_id,mobile_no)
values(1, 'A', 'xyz',12345),(2, 'B', 'abc',99999),(3, 'C', 'LMN',100000);
-- Whenever we insert new records it will be inserted automatically in table2
insert into student_details(student_id,student_name,mail_id,mobile_no)
values(4, 'D', 'liv',888888);

-- STEP 4: Updating Values in Table 1 and check table 2 whether the updated record is there  
update student_details
set mobile_no = 123456789
where student_id = 1;


select *
from student_details;
select *
from student_details_backup;

-- drop trigger if exists backup_update;
-- drop trigger if exists backup_insert;
-- drop table student_details;
-- drop table student_details_backup;