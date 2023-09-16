/* Note, I didn't find a requirement on software, so I used MySql, but can use different employment if needed.
I have included comments trhoughout to clarify decisions and to record any important notes. */


/* 1. Write a query to get the sum of impressions by day. */

    -- Assuming the question has not asked 'day of the week', so I will use the date
    -- Sum the number of impressions per calendar day (or date)
    -- For clarity and organizational purposes, I will order output by the date

select DATE(date) as date, sum(impressions) as sum_impressions from marketing_data
group by DATE(date)
order by DATE(date) asc;





/* 2. Write a query to get the top three revenue-generating states in order of best to worst. 
How much revenue did the third-best state generate? */

    -- There are two ways to go about ties (in case we encounter them): 1, we output all 
    -- the states that generate the top three revenues
    -- or 2, we create a tie-breaker so we choose the best answers since we only return three
    -- Note that I did not include the total revenue values for the first part of this question,
    -- but did find it separately for the third highest state for demonstration purposes

        -- Method 1: all states that create the top three revenues
        -- Join on values to filter all the total revenues by state to the top three earned revenues by state

with top_revs as (select distinct sum(revenue) as total_revenue from website_revenue
group by state
order by sum(revenue) desc
limit 3)
select state from website_revenue
group by state
having sum(revenue) in (select * from top_revs)
order by sum(revenue) desc;

        -- Method 2: top three (with tie-breaking variable: alphabetical order)
        -- Limit to 3 values

select state from website_revenue
group by state
order by sum(revenue) desc, state 
limit 3;

        -- Third-best state revenue (using method 2 as both methods yield same result in this case)
        -- Using offset to find values at certain positions after ordering

select state, sum(revenue) as total_revenue from website_revenue
group by state
order by sum(revenue) desc, state
limit 1 offset 2;

-- The third best state revenue was from Ohio at $37,577.





/* 3. Write a query that shows total cost, impressions, clicks, and revenue of each campaign. 
Make sure to include the campaign name in the output. */

    -- Must join with website_revenue to find total revenue
    -- Must join with campaign_info for the name of the campaigns
    -- round the cost since it wouldn't make sense to have cent values more than two decimal points

select name, round(sum(cost),2) as total_cost, sum(impressions) as total_impressions, sum(clicks) as total_clicks, 
    sum(revenue) as total_revenue from marketing_data
join website_revenue on website_revenue.campaign_id = marketing_data.campaign_id
join campaign_info on campaign_info.id = marketing_data.campaign_id
group by marketing_data.campaign_id;





/* 4. Write a query to get the number of conversions of Campaign5 by state. 
Which state generated the most conversions for this campaign? */

with Campaign5_data as (select * from marketing_data 
join campaign_info on marketing_data.campaign_id = campaign_info.id
having campaign_info.name = 'Campaign5'),
valid_count as (select geo, sum(conversions) as total_conversions from Campaign5_data
group by geo)
select distinct marketing_data.geo, ifnull(total_conversions, 0) as total_conversions from marketing_data
left join valid_count on valid_count.geo = marketing_data.geo
order by total_conversions desc;

        -- Just by looking at the output, it can be noted that the answer is Georgia, but 
        -- for demonstration purposes, the addition of an extra part as shown below can give us the answer

with Campaign5_data as (select * from marketing_data 
join campaign_info on marketing_data.campaign_id = campaign_info.id
having campaign_info.name = 'Campaign5'),
valid_count as (select geo, sum(conversions) as total_conversions from Campaign5_data
group by geo)
select marketing_data.geo from marketing_data
left join valid_count on valid_count.geo = marketing_data.geo
order by total_conversions desc limit 1;

-- As demonstrated, the state with the most conversions for this campaign is Georgia.





/* 5. In your opinion, which campaign was the most efficient, and why? */

    -- efficiency: most number of conversions in the least amount of time
    -- need to calculate the rate of conversion

    -- max date for each campagin - min date which is the total number of days the
    -- campaign ran for

with total_campaign_convs as (select campaign_id, 
    sum(conversions) as sum_convs from marketing_data
group by campaign_id),
days_running as (select campaign_id, datediff(max(date), min(date)) as days from marketing_data
    group by campaign_id)
select name, sum_convs/days as rate from days_running
join total_campaign_convs on total_campaign_convs.campaign_id = days_running.campaign_id
join campaign_info on days_running.campaign_id = campaign_info.id
order by rate desc;

-- The most efficient campaign is Campaign 3 as it brought the most number of conversion rates





/* 6. Write a query that showcases the best day of the week (e.g., Sunday, Monday, Tuesday, etc.) to run ads. */

    -- I used a bit of domain knowledge through research to find that conversions are one of the most important 
    -- metrics to be able to answer this question in a useful way. Then I went tie breaker decision to use clicks
    -- then impressions to order output from "best" to "worst"

select dayname(date) as day_of_week, sum(conversions) as total_convs from marketing_data
group by dayname(date)
order by sum(conversions) desc, sum(clicks) desc, sum(impressions) desc;









