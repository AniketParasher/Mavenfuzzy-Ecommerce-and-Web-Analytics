---------------------------------- MAVENFUZZY FACTORY ECOMMERCE AND WEBSITE ANALYSIS -----------------------------------

# Take a look what data tables have in them

Select * from website_sessions; # table contain information related to different source of taffic
Select * from website_pageviews; # table contains information about different page visits
Select * from orders; # table contains information about orders

------------------------ TRAFFIC SOURCE ANALYSIS -------------------------------

# Manager : can you find different source of traffic by utm_source, utm_campaign, http_referer

SELECT 
    utm_source,   # which source the traffic comining on website
    utm_campaign, # campaign running on the source
    http_referer, # search engine through which traffic comes
    COUNT(website_session_id) AS sessions
FROM
    website_sessions
WHERE
    DATE(created_at) < '2012-11-27'
GROUP BY 1 , 2, 3
ORDER BY 4 DESC;

# Analysis - shows gsearch non brand has high traffic

------------------------------------------------------------------------------------------------------------

# Manager: Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions
# and orders so that we can showcase the growth there?

SELECT 
     MIN(DATE(ws.created_at)) AS start_month,
     COUNT(DISTINCT ws.website_session_id) AS sessions,
     COUNT(DISTINCT order_id) AS orders,
     COUNT(DISTINCT order_id)/COUNT(DISTINCT ws.website_session_id)*100 as cnv_rate
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE utm_source = 'gsearch'
      AND ws.created_at < '2012-11-27'
GROUP BY Month(ws.created_at);

# Analysis - this shows not only number of gsearch sessions, orders are increasing but conversion rate is also increasing

------------------------------------------------------------------------------------------------------------------------

-- Manager: Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out 
-- nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. 
-- If so, this is a good story to tell.  

SELECT 
     MIN(DATE(ws.created_at)) as start_week,
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE NULL END) AS non_brand_sessions,
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) as non_brand_orders, 
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE NULL END)*100 as non_cnv_rate,
     COUNT(CASE WHEN utm_campaign = 'brand' THEN 1 ELSE NULL END) AS brand_sessions,
     COUNT(CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) as brand_orders,
     COUNT(CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN utm_campaign = 'brand' THEN 1 ELSE NULL END)*100 as brd_cnv_rate
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE utm_source = 'gsearch'
      AND ws.created_at < '2012-11-27'
GROUP BY MONTH(ws.created_at);

# Analysis - we see non brand conversion rate is increasing with brand campaign conversion rate is decreasing

---------------------------------------------------------------------------------------------------------------

-- Manger: Calculate the conversion rate (CVR) from session to order for gsearch non brand campaign

SELECT 
     COUNT(distinct ws.website_session_id) AS sessions,
     COUNT(distinct od.order_id) as orders,
     (COUNT(distinct od.order_id)/COUNT(distinct ws.website_session_id))*100 AS session_to_order_cvt_rate
FROM website_sessions AS ws
LEFT JOIN orders AS od
ON ws.website_session_id = od.website_session_id
WHERE 
     ws.created_at < '2012-11-27' AND
     utm_source = "gsearch" AND utm_campaign = "nonbrand";
     
# Analysis- this gives overall idea about sessions to order conversion for gsearch, non brand campaign

--------------------------------------------------------------------------------------------------------------
     
-- Manager: Pull conversion rates from session to order, by device type

SELECT 
     device_type,
     COUNT(DISTINCT ws.website_session_id) AS sessions,
     COUNT(DISTINCT order_id) AS orders,
     COUNT(DISTINCT order_id)/COUNT(DISTINCT ws.website_session_id)*100 AS 'session_to_order_conv_rate%'
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY 1;

# Analysis: desktop seems to be high driver of business

------------------------------------------------------------------------------------------------------------

-- Manager: show weekly trend for both mobile and desktop

SELECT 
     MIN(DATE(created_at)) as start_week,
     COUNT(CASE WHEN device_type = 'mobile' THEN 1 ELSE NULL END) as mobile_sessions,
     COUNT(CASE WHEN device_type = 'desktop' THEN 1 ELSE NULL END) as desktop_sessions
FROM website_sessions
WHERE created_at < '2012-11-27' AND
      utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

# Analysis- desktop session is increasing with a spike in month on november and similar spike in mobile sessions also
-- the spike might have relation with seasonality which we will understand in business pattern and seasonality

---------------------------------------------------------------------------------------------------------------------

-- Manager: While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders 
-- split by device 3 type? I want to flex our analytical muscles a little and 
-- show the board we really know our traffic sources.

SELECT
     MIN(DATE(ws.created_at)) as start_week,
     COUNT(CASE WHEN device_type = 'desktop' THEN 1 ELSE NULL END) as desktop_sessions,
     COUNT(CASE WHEN device_type = 'desktop' THEN order_id ELSE NULL END) as desktop_orders,
     COUNT(CASE WHEN device_type = 'mobile' THEN 1 ELSE NULL END) AS mobile_sessions,
     COUNT(CASE WHEN device_type = 'mobile' THEN order_id ELSE NULL END) AS mobile_orders
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
      AND ws.created_at < '2012-11-27'
GROUP BY MONTH(ws.created_at);

# Analysis- desktop orders are increasing on monthly basis but mobile orders are stagnant 

---------------------------------------------------------------------------------------------------------------------

-- Manager: I’m worried that one of our more pessimistic board members may be concerned about the 
-- large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, 
-- alongside monthly trends for each of our other channels?

SELECT
     MIN(DATE(created_at)) as start_week,
     COUNT(CASE WHEN utm_source = 'gsearch' THEN 1 ELSE NULL END) as gsearch_sessions,
     COUNT(CASE WHEN utm_source = 'bsearch' THEN 1 ELSE NULL END) as bsearch_sessions,
     COUNT(CASE WHEN http_referer is not null AND utm_source is null AND utm_campaign is null 
     THEN 1 ELSE NULL END) as organic_sessions,
     COUNT(CASE WHEN http_referer is null THEN 1 ELSE NULL END) as direct_search_sessions
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY MONTH(created_at);

---------------------------- WEBSITE ANALYSIS ----------------------------

-- For website analysis the tables we need are website_sessions, website_pageviews and orders
SELECT * FROM website_pageviews;
SELECT DISTINCT pageview_url FROM website_pageviews;

----------------------------------------------------------------------------------------------------------------

-- Manager: Show me most viewed website pages, ranked by session volume

SELECT 
pageview_url,
COUNT(website_session_id) as view_count
FROM website_pageviews 
WHERE created_at < '2012-06-09' # calculated till this date
GROUP BY pageview_url
ORDER BY view_count DESC;

# Analysis- our website home page viewed most followed by product page

------------------------------------------------------------------------------------------------------------------

-- top ENTRY PAGE

WITH cte AS (
SELECT * FROM
website_pageviews 
WHERE website_pageview_id IN (
							SELECT 
                            MIN(website_pageview_id) 
                            FROM website_pageviews
                            WHERE created_at < '2012-06-12' # date
                            GROUP BY website_session_id))
SELECT
     c.pageview_url,
     COUNT(website_pageview_id) as page_visits
FROM cte as c
GROUP BY pageview_url;

-- We will find the first pageview for relevant sessions, associate that pageview with the url seen, 
-- then analyze whether that session had additional pageviews
-- This temporary table only contains entry page data per session

CREATE TEMPORARY TABLE entry_page_per_session
SELECT * FROM
website_pageviews 
WHERE website_pageview_id IN (
							SELECT 
                            MIN(website_pageview_id) 
                            FROM website_pageviews
                            GROUP BY website_session_id);
                            
SELECT 
     pageview_url,
	 COUNT(website_pageview_id)
FROM entry_page_per_session
WHERE created_at < '2012-06-12' # date
GROUP BY pageview_url;

# Finding which page has bounce means customer visited first page and left, table contain bounced sessions

CREATE TEMPORARY TABLE Bounce_only # this will include website sessions which bounced
SELECT 
    website_session_id, COUNT(website_pageview_id) as Count_page_visit
FROM
    website_pageviews
GROUP BY 
    website_session_id
HAVING 
    Count_page_visit = 1;
    
# Joining first_page_view table and bounce table

SELECT 
    COUNT(ep.website_session_id) AS Sessions,
    COUNT(bo.website_session_id) AS Bounce,
    COUNT(bo.website_session_id) / COUNT(ep.website_session_id) AS bounce_rate
FROM
    entry_page_per_session ep
        LEFT JOIN
    Bounce_only bo ON ep.website_session_id = bo.website_session_id
WHERE
    created_at < '2012-06-14' # date
    AND pageview_url = '/home';
    
# Analysis- current home page as of 14 june 2012 has bounce rate of 59.18 %

-------------------------------------------------------------------------------------------------------------------

-- Website manager introduced a new home page named as lander-1

-- Manager: we did 50-50 A/B test for lander 1 and home page, can analyse the performance of each

# Entry page table for each session is created in previous questions will be used here
CREATE TEMPORARY TABLE A_B_entry_page
SELECT 
    ep.website_pageview_id,
    ep.website_session_id,
    ep.pageview_url
FROM
    entry_page_per_session ep
LEFT JOIN
    website_sessions ws
ON ep.website_session_id = ws.website_session_id
WHERE
    ep.created_at > (SELECT 
		MIN(created_at) # it will return date when lander-1 page was launched so that we can have fair comparison
        FROM
            website_pageviews
        WHERE
            pageview_url LIKE '/lander-1')
        AND ep.created_at < '2012-07-28' # date
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand';

SELECT 
     pageview_url,
     COUNT(ab.website_session_id) as sessions,
     COUNT(bo.website_session_id) as bounce,
	COUNT(bo.website_session_id)/COUNT(ab.website_session_id) as bounce_rate
FROM A_B_entry_page ab
LEFT JOIN
bounce_only bo # temporary table created in previous query
ON ab.website_session_id = bo.website_session_id
GROUP BY pageview_url;

# Analysis- we can see lander-1 performed well with low bounce rate

--------------------------------------------------------------------------------------------------------------------

-- Manager: Build as full conversion funnel, analysing how is the conversion rate of each page

# below table will have page level information where 1 means user visited and 0 means not for each website sessions
CREATE TEMPORARY TABLE page_level_info  
SELECT 
      website_session_id,
      MAX(product_page) as product_made_it,
      MAX(mr_fuzzy_page) as mr_fuzzy_made_it,
      MAX(cart_page) as cart_made_it,
      MAX(shiping_page) as shipping_made_it,
      MAX(billing_page) as billing_made_it,
      MAX(thank_you_page) as thankyou_made_it
FROM 
     (  # this table will create unique columns for all pages using case statement for gsearch and nonbrand
     SELECT 
     ws.website_session_id,
     wp.pageview_url,
     CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END as product_page,
     CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END as mr_fuzzy_page,
     CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page,
     CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END as shiping_page,
     CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END as billing_page,
     CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END as thank_you_page
FROM website_pageviews wp
INNER JOIN website_sessions ws
ON ws.website_session_id = wp.website_session_id
WHERE wp.created_at between '2012-08-05' and '2012-09-05'
      AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
Order by wp.website_session_id, wp.created_at
) AS pageview_level
GROUP BY website_session_id;

SELECT
     COUNT(website_session_id) as lander_visits, # total sessions happened
     SUM(product_made_it) as product_visits, # this gives out of total sessions how many user visited this page
     SUM(mr_fuzzy_made_it) as mr_fuzzy_visits, # out of product visits how many visited mr_fuzzy page
     SUM(cart_made_it) as cart_visits,
     SUM(shipping_made_it) as shipping_visits,
	 SUM(billing_made_it) as billing_visits,
	 SUM(thankyou_made_it) as thankyou_visits
FROM page_level_info;

# conversion rate
SELECT
     # after visting lander page what is conversion rate, it give page performance
     SUM(product_made_it)/COUNT(website_session_id) as lander_cnv_rate, 
     SUM(mr_fuzzy_made_it)/SUM(product_made_it) as product_cnv_rate,
     SUM(cart_made_it)/SUM(mr_fuzzy_made_it) as mr_fuzzy_cnv_rate,
     SUM(shipping_made_it)/SUM(cart_made_it) as cart_cnv_rate,
	 SUM(billing_made_it)/SUM(shipping_made_it) as shipping_cnv_rate,
	 SUM(thankyou_made_it)/SUM(billing_made_it) as billing_cnv_rate
FROM page_level_info;

# Analysis- here we can see conversion rate for each page, with mr_fuzzy and billing page has low conversion rate

-------------------------------------------------------------------------------------------------------------------

-- Manager: we can see billing page conversion rate is low so website manager introduced another page
-- now it is time to conduct A/B test for billing and see how new page performs compared to old billing page

CREATE TEMPORARY TABLE billing_page
SELECT 
    website_session_id, pageview_url
FROM
    website_pageviews
WHERE
    pageview_url IN ('/billing' , '/billing-2')
        AND created_at BETWEEN (SELECT 
            MIN(created_at) # this returns date when new billing page was introduced
        FROM
            website_pageviews
        WHERE
            pageview_url = '/billing-2') AND '2012-11-10';


# bounced sessions id for each page which will help to evalute on which page users left the most

CREATE TEMPORARY TABLE bounce_session_only
SELECT website_session_id as bounce_session_id,
	   Count(website_pageview_id) as page_count
FROM website_pageviews
WHERE
    pageview_url IN ('/billing' , '/billing-2', '/thank-you-for-your-order')
group by website_session_id
HAVING Count(website_pageview_id) = 1;


SELECT 
     pageview_url,
     COUNT(website_session_id) as sessions,
     (COUNT(website_session_id) - COUNT(bounce_session_id)) as orders, # gives how many landed to thank page
     (COUNT(website_session_id) - COUNT(bounce_session_id))/COUNT(website_session_id)*100 AS bill_to_order_rt
FROM billing_page bp
LEFT JOIN bounce_session_only bs
ON bp.website_session_id = bs.bounce_session_id
GROUP BY pageview_url;

# It is clear from above analysis that billing-2 has high bill to order conversion 62.69 %

---------------------------------- CHANNEL PORTFOLIO ANALYSIS --------------------------------------

-- Analysing utm_content, sessions, orders and conversion_rate --

SELECT
     utm_content,
     COUNT(ws.website_session_id) as sessions,
     COUNT(od.order_id) as orders,
     COUNT(od.order_id)/COUNT(ws.website_session_id)*100 as conversion_rate
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1
ORDER BY 2 DESC;

-- Weekly trend for gsearch and bsearch based on non brand campaign--

SELECT 
     MIN(DATE(created_at)) AS start_week,
     COUNT(CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
     COUNT(CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions ws
WHERE created_at > '2012-08-22' AND
      created_at < '2012-11-29' AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);

-- weekly trend for bsearch Could you please pull the percentage of traffic coming on Mobile, and compare that to gsearch?

SELECT 
     utm_source,
     COUNT(website_session_id) as sessions,
     COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) as mobile_session,
     COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)
     /COUNT(website_session_id)*100 as pct_mobile
FROM website_sessions
WHERE 
      created_at > '2012-08-22' AND
      created_at < '2012-11-30' AND
      utm_source IN ('gsearch', 'bsearch') AND
      utm_campaign = 'nonbrand'
GROUP BY utm_source;

---------------------------------------------------------

-- Could you pull nonbrand conversion rates from session to order for gsearch and bsearch, and slice the
-- data by device type?

SELECT 
	 device_type,
     utm_source,
     COUNT(ws.website_session_id) AS total_sessions,
     COUNT(order_id) AS orders,
     COUNT(order_id)/COUNT(ws.website_session_id)*100 as conversion_rate
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at > '2012-08-22'
      AND ws.created_at < '2012-09-19'
      AND utm_campaign = 'nonbrand'
GROUP BY device_type, utm_source
ORDER BY device_type;

-------------------------------------------------------

-- Can you pull weekly session volume for gsearch and bsearch nonbrand, broken down by device, 
-- since November 4th? If you can include a comparison metric to show bsearch as a
-- percent of gsearch for each device

WITH CTE AS (
SELECT 
     MIN(DATE(created_at)) AS start_week,
     COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) as gsearch_dtop,
     COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) as bsearch_dtop,
     COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) as gsearch_mobile,
     COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) as bsearch_mobile
FROM website_sessions
WHERE 
      created_at > '2012-11-04'
      AND created_at < '2012-12-22'
      AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at))

SELECT *, 
     CONCAT((bsearch_dtop/gsearch_dtop)*100, ' %') AS dtop_bsrch_of_gsrch,
     CONCAT((bsearch_mobile/gsearch_mobile)*100, ' %') AS mob_bsrch_of_gsrch
FROM cte;

---------------------------------------------------------------------

-- 62 Analyzing direct traffic

SELECT
     CASE
         WHEN http_referer IS NULL THEN 'direct_type_in' # http_referer null means it user is directly typing out website name
         WHEN http_referer = 'https://www.gsearch.com' AND utm_source IS NULL THEN 'gsearch_organic' # utm_source null means not a paid traffic
         WHEN http_referer = 'https://www.bsearch.com' AND utm_source IS NULL THEN 'bsearch_organic'
         ELSE 'Other'
         END AS Traffic_source,
	 COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE -- website_session_id BETWEEN 100000 AND 115000
created_at < '2012-11-27'
GROUP BY 1
ORDER BY 2 DESC;

-- Could you pull organic search, direct type in, and paid brand search sessions by month, and show those sessions
-- as a % of paid search nonbrand?

SELECT 
     YEAR(created_at) Year,
     MONTH(created_at) Month,
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand_sessions,
     COUNT(CASE WHEN utm_campaign = 'brand' THEN 1 ELSE NULL END) AS brand_sessions,
     COUNT(CASE WHEN utm_campaign = 'brand' THEN 1 ELSE NULL END)/
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE NULL END) * 100 AS brnd_pct_of_nonbrnd,
     COUNT(CASE WHEN http_referer IS NULL AND utm_source IS NULL THEN 1 ELSE NULL END) AS direct_sessions,
	 COUNT(CASE WHEN http_referer IS NULL AND utm_source IS NULL THEN 1 ELSE NULL END)/
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE NULL END) * 100 AS direct_pct_of_nonbrnd,
     COUNT(CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN 1 ELSE NULL END) AS organic_sessions,
     COUNT(CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN 1 ELSE NULL END)/
     COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE NULL END) * 100 AS organic_pct_of_nonbrnd
FROM website_sessions
WHERE created_at < '2012-12-23'
GROUP BY 
       YEAR(created_at),
	   MONTH(created_at);
       
-------------------------------- BUSINESS PATTERN AND SEASONALITY ANALYSIS -------------------------------------

-- Understanding Seasonality on monthly basis--

SELECT
     MIN(DATE(ws.created_at)) AS start_month,
     COUNT(ws.website_session_id) as sessions,
     COUNT(order_id) as orders
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at < '2013-01-02'
GROUP BY MONTH(ws.created_at);

# Analysis- sessions and orders are increasing with spike in month of november due to thanks giving day and vacation time

---------------------------------------------------------------------------------------------------------------------

-- Understanding Seasonality on weekly basis--

SELECT
     MIN(DATE(ws.created_at)) AS start_month,
     COUNT(ws.website_session_id) as sessions,
     COUNT(order_id) as orders
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at < '2013-01-02'
GROUP BY YEARWEEK(ws.created_at);

# Analysis- 18th November has highest spike in orders as it is sunday before thanks giving

----------------------------------------------------------------------------------------------------------------------

-- Manager: Could you analyze the average website session volume, by hour of day and by day week, 
-- so that we can staff appropriately? 

CREATE TEMPORARY TABLE session_day_time
SELECT website_session_id, HOUR(created_at) as Hour, 
CASE WHEN WEEKDAY(created_at) = 0 THEN 'Monday'
     WHEN WEEKDAY(created_at) = 1 THEN 'Tuesday'
     WHEN WEEKDAY(created_at) = 2 THEN 'Wednesday'
     WHEN WEEKDAY(created_at) = 3 THEN 'Thursday'
     WHEN WEEKDAY(created_at) = 4 THEN 'Friday'
     WHEN WEEKDAY(created_at) = 5 THEN 'Saturday'
     WHEN WEEKDAY(created_at) = 6 THEN 'Sunday'
     END AS DayName
FROM website_sessions
WHERE created_at > '2012-09-15'
      AND created_at < '2012-11-15';

SELECT
    Hour,
    COUNT(CASE WHEN DayName = 'Monday' THEN 1 ELSE NULL END) AS Mon,
    COUNT(CASE WHEN DayName = 'Tuesday' THEN 1 ELSE NULL END) AS Tue,
    COUNT(CASE WHEN DayName = 'Wednesday' THEN 1 ELSE NULL END) AS Wed,
    COUNT(CASE WHEN DayName = 'Thursday' THEN 1 ELSE NULL END) AS Thurs,
    COUNT(CASE WHEN DayName = 'Friday' THEN 1 ELSE NULL END) AS Fri,
    COUNT(CASE WHEN DayName = 'Saturday' THEN 1 ELSE NULL END) AS Sat,
    COUNT(CASE WHEN DayName = 'Sunday' THEN 1 ELSE NULL END) AS Sun
FROM session_day_time
GROUP BY Hour
ORDER BY Hour;


SELECT 
     hour_of_day,
     ROUND(AVG(CASE WHEN Week_day = 0 THEN website_sessions ELSE NULL END),1) as mon,
     ROUND(AVG(CASE WHEN Week_day = 1 THEN website_sessions ELSE NULL END),1) as Tue,
     ROUND(AVG(CASE WHEN Week_day = 2 THEN website_sessions ELSE NULL END),1) as Wed,
     ROUND(AVG(CASE WHEN Week_day = 3 THEN website_sessions ELSE NULL END),1) as Thur,
     ROUND(AVG(CASE WHEN Week_day = 4 THEN website_sessions ELSE NULL END),1) as Fri,
     ROUND(AVG(CASE WHEN Week_day = 5 THEN website_sessions ELSE NULL END),1) as Sat,
     ROUND(AVG(CASE WHEN Week_day = 6 THEN website_sessions ELSE NULL END),1) as Sun
FROM
(SELECT
     DATE(created_at) as created_at,
     WEEKDAY(created_at) as Week_day,
     HOUR(created_at) as hour_of_day,
     COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3) AS daily_hourly_Sessions
GROUP BY 1
order by 1;

------------------------------------------------ PRODUCT ANALYSIS ----------------------------------------------------

-- Analyzing product sales helps you understand how each product contributes to
-- your business, and how product launches impact the overall portfolio


-- Calculating KPIs --

SELECT
     COUNT(order_id) as Orders,
     SUM(price_usd) as Revenue,
     SUM(price_usd - cogs_usd) as Margin,
	 AVG(price_usd) as average_order_value
FROM orders
WHERE 
     order_id BETWEEN 100 AND 200;
     
------------------------------------------------

SELECT
     product_name,
     COUNT(order_id) as orders,
     SUM(price_usd) as Revenue,
     SUM(price_usd - cogs_usd) as Margin,
     AVG(price_usd) as aov
FROM orders od
INNER JOIN products pd
ON od.primary_product_id = pd.product_id
WHERE order_id BETWEEN 10000 and 11000
GROUP BY product_name;

-- Can you please pull monthly trends to date for number of sales, total revenue, and total margin generated for the
-- business?

SELECT
     YEAR(created_at) year, MONTH(created_at) month,
     COUNT(order_id) orders,
	 SUM(price_usd) as Revenue,
     SUM(price_usd - cogs_usd) as Margin
FROM orders od
WHERE created_at < '2013-01-04'
GROUP BY YEAR(created_at), MONTH(created_at);

-- I’d like to see monthly order volume, overall conversion rates, revenue per session, and a breakdown of sales by
-- product, all for the time period since April 1, 2012.

SELECT
     YEAR(ws.created_at) yr, MONTH(ws.created_at) mo,
     COUNT(order_id) as orders,
     (COUNT(order_id)/COUNT(ws.website_session_id) * 100) as conversion_rate,
     SUM(price_usd)/COUNT(ws.website_session_id) as Revenue,
     COUNT(CASE WHEN primary_product_id = 1 THEN 1 ELSE NULL END) as product_one_orders,
     SUM(CASE WHEN primary_product_id = 1 THEN price_usd ELSE 0 END) as product_one_revenue,
     SUM(CASE WHEN primary_product_id = 2 THEN price_usd ELSE 0 END) as product_second_revenue
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at > '2012-04-01' AND ws.created_at < '2013-04-05'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at);

---------------------------------------------------------------

---------------------------------------------- PRODUCT LEVEL WEBSITE ANALYSIS --------------------------------------

-- Product-focused website analysis is about learning how customers interact
-- with each of your products, and how well each product converts customers

SELECT wp.pageview_url,
       COUNT(wp.website_pageview_id) as sessions,
       COUNT(od.order_id) as orders,
       COUNT(od.order_id)/
       COUNT(wp.website_pageview_id)*100 as cnv_rate
FROM website_pageviews wp
LEFT JOIN orders od
ON wp.website_session_id = od.website_session_id
WHERE pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
      AND wp.created_at BETWEEN '2013-02-01' AND '2013-03-01'
GROUP BY pageview_url;

-------------------------------------------------------------------------------------------------------------

SELECT 
     CASE WHEN created_at < '2013-01-06' THEN 'A.Pre_Product_2' ELSE 'B.Post_Product_2' END AS time_period,
     SUM(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) as sessions,
     SUM(CASE WHEN pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear') THEN 1 ELSE 0 END) AS next_page,
     SUM(CASE WHEN pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear') THEN 1 ELSE 0 END)/
     SUM(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END)*100 as pct_next_page,
     SUM(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS fuzzy_page,
     SUM(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END)/
     SUM(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END)*100 as pct_fuzzy_page ,
     SUM(CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END) AS love_bear_page,
     SUM(CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END)/
     SUM(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END)*100 as pct_love_bear_page
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
GROUP BY time_period;

-----------------------------------------------------------------------------------------------------------------------------

-- conversion funnels from each product page to conversion. comparison between the two conversion funnels, for all website traffic

CREATE TEMPORARY TABLE product_entry_page
SELECT website_session_id, 
      pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
      AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');

-- Count of session 
SELECT 
     pe.pageview_url,
     COUNT(DISTINCT pe.website_session_id) as sessions,
     SUM(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) as cart_page,
     SUM(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) as shipping_page,
     SUM(CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END) as billing_page,
     SUM(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) as thankyou_page
FROM product_entry_page pe
LEFT JOIN website_pageviews wp
ON pe.website_session_id = wp.website_session_id
GROUP BY pe.pageview_url;

-- click rate
SELECT 
     pe.pageview_url,
     SUM(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END)/
     COUNT(DISTINCT pe.website_session_id)*100 as product_page_click_rt,
     SUM(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END)/
     SUM(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END)*100 as cart_page_click_rt,
     SUM(CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END)/
     SUM(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END)*100 as shipping_page_click_rt,
     SUM(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END)/
     SUM(CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END)*100 as billing_page_click_rt
FROM product_entry_page pe
LEFT JOIN website_pageviews wp
ON pe.website_session_id = wp.website_session_id
GROUP BY pe.pageview_url;

-------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------- CROSS-SELLING PRODUCTS -------------------------------------------

-- Cross-sell analysis is about understanding which products users are most likely to purchase together, 
-- and offering smart product recommendations

WITH cte1 as (SELECT order_id FROM orders WHERE items_purchased > 1 AND order_id BETWEEN 10000 AND 11000),
cte2 as (
SELECT
     cte1.order_id,
     SUM(CASE WHEN is_primary_item = 1 THEN product_id ELSE NULL END) as primary_product,
     SUM(CASE WHEN is_primary_item = 0 THEN product_id ELSE NULL END) as secondary_product
FROM order_items ot
INNER JOIN cte1
ON ot.order_id = cte1.order_id
GROUP BY cte1.order_id),

cte3 as (
SELECT 
      primary_product, 
      secondary_product, 
      COUNT(order_id) AS orders 
FROM cte2 
GROUP BY primary_product, secondary_product
ORDER BY 1)

SELECT
     primary_product,
     SUM(CASE WHEN secondary_product = 1 THEN orders ELSE 0 END) as with_product_1,
     SUM(CASE WHEN secondary_product = 2 THEN orders ELSE 0 END) as with_product_2,
     SUM(CASE WHEN secondary_product = 3 THEN orders ELSE 0 END) as with_product_3
FROM cte3
GROUP BY primary_product;

-- OR --

SELECT 
      primary_product_id,
      COUNT(order_id) as orders,
      SUM(CASE WHEN product_id = 1 THEN 1 ELSE 0 END) as product_1,
      SUM(CASE WHEN product_id = 2 THEN 1 ELSE 0 END) as product_2,
      SUM(CASE WHEN product_id = 3 THEN 1 ELSE 0 END) as product_3
      FROM
      (
       SELECT
	        od.order_id,
            primary_product_id,
            product_id
	   FROM orders od
	   LEFT JOIN order_items ot
       ON od.order_id = ot.order_id
       AND ot.is_primary_item = 0
       WHERE od.order_id BETWEEN 10000 AND 11000
       ) as x
GROUP BY primary_product_id
ORDER BY 1;

---------------------------------------------------------------------------------------------------------------

-- On September 25th we started giving customers the option to add a 2nd product while on the /cart page. Morgan says
-- this has been positive, but I’d like your take on it. Could you please compare the month before vs the month
-- after the change? I’d like to see CTR from the /cart page, Avg Products per Order, AOV, and overall revenue per/cart page view.

SELECT 
    time_period,
	SUM(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page_session,
    SUM(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS click_throughs,
    SUM(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END)/
    SUM(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END)*100 as ctr_cart,
    AVG(items_purchased) as products_per_order,
    AVG(price_usd) as AOV,
    SUM(CASE WHEN pageview_url = '/cart' THEN price_usd ELSE 0 END) as Revenue,
    SUM(CASE WHEN pageview_url = '/cart' THEN price_usd ELSE 0 END)/
    SUM(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) as rev_per_cart_sessions
	FROM 
    (
    SELECT
         wp.website_session_id,
         wp.website_pageview_id,
         wp.pageview_url,
         od.items_purchased,
         od.price_usd,
		 wp.created_at,
	     CASE WHEN wp.created_at < '2013-09-25' THEN 'A.Pre_Cross_Sell' 
              WHEN wp.created_at >= '2013-09-25' THEN 'B.Post_Cross_Sell' 
              ELSE 'Other_logic' END as time_period
	FROM website_pageviews wp
    LEFT JOIN orders od
    ON wp.website_session_id = od.website_session_id
    WHERE wp.created_at BETWEEN '2013-08-25' AND '2013-10-25'
    ) AS x
GROUP BY 1;

---------------------------------------------------------------------------------------------------------------------

-- On December 12th 2013, we launched a third product targeting the birthday gift market (Birthday Bear).
-- Could you please run a pre-post analysis comparing the month before vs. the month after, 
-- in terms of session-to-order conversion rate, AOV, products per order, and revenue per session?

SELECT 
      time_stamp,
      COUNT(DISTINCT order_id) as orders,
      COUNT(DISTINCT order_id)/
      COUNT(DISTINCT website_session_id) as sessions_to_ord_cnv,
      AVG(price_usd) as aov,
      AVG(items_purchased),
      SUM(CASE WHEN pageview_url = '/cart' THEN price_usd ELSE 0 END)/
      COUNT(DISTINCT website_session_id) as rev_per_session
      FROM
      (
       SELECT 
            order_id,
            wp.website_session_id,
            wp.created_at,
            items_purchased,
            pageview_url,
            od.price_usd,
            CASE WHEN wp.created_at < '2013-12-12' THEN 'A.Pre_Birthday_Bear'
            WHEN wp.created_at >= '2013-12-12' THEN 'B.Post_Birthday_Bear'
            END as time_stamp
	   FROM website_pageviews wp
       LEFT JOIN 
       orders od
       ON wp.website_session_id = od.website_session_id
       WHERE wp.created_at BETWEEN '2013-11-12' 
                            AND '2014-01-12'
	   ) AS x
       GROUP BY time_stamp;

------------------------------------------------ PRODUCT REFUND ANALYSIS ------------------------------------------------

-- Analyzing product refund rates is about controlling for quality and 
-- understanding where you might have problems to address

SELECT 
     MIN(DATE(ot.created_at)) AS start_month,
     COUNT(CASE WHEN product_id = 1 THEN ot.order_item_id else null END) as Product_1_orders,
	 SUM(CASE WHEN oir.order_item_id is not null AND product_id = 1 THEN 1 else 0 END)/
     COUNT(CASE WHEN product_id = 1 THEN ot.order_item_id else null END) as Product_1_rate,
     COUNT(CASE WHEN product_id = 2 THEN ot.order_item_id else null END) as Product_2_orders,
     SUM(CASE WHEN oir.order_item_id is not null AND product_id = 2 THEN 1 else 0 END)/
     COUNT(CASE WHEN product_id = 2 THEN ot.order_item_id else null END) as Product_2_rate,
     COUNT(CASE WHEN product_id = 3 THEN ot.order_item_id else null END) as Product_3_orders,
     SUM(CASE WHEN oir.order_item_id is not null AND product_id = 3 THEN 1 else 0 END)/
     COUNT(CASE WHEN product_id = 3 THEN ot.order_item_id else null END) as Product_3_rate,
     COUNT(CASE WHEN product_id = 4 THEN ot.order_item_id else null END) as Product_4_orders,
     SUM(CASE WHEN oir.order_item_id is not null AND product_id = 4 THEN 1 else 0 END)/
     COUNT(CASE WHEN product_id = 4 THEN ot.order_item_id else null END) as Product_4_rate
FROM order_items ot
LEFT JOIN order_item_refunds oir
ON ot.order_item_id = oir.order_item_id
WHERE ot.created_at < '2014-10-15'
GROUP BY YEAR(ot.created_at),
         MONTH(ot.created_at);
         
 ----------------------------------------------- USER ANALYSIS -----------------------------------------------------

-------------------------------------------- ANALYZE REPEAT BEHAVIOR -----------------------------------------------

-- Analyzing repeat visits helps you understand user behavior and identify some of your most valuable customers

-- Could you please pull data on how many of our website
-- visitors come back for another session? 2014 to date is good.

CREATE TEMPORARY TABLE sessions_w_repeats
SELECT 
     new_sessions.user_id,
     new_sessions.website_session_id AS new_session_id,
     website_sessions.website_session_id AS repeat_session_id
FROM
(
SELECT 
     user_id,
     website_session_id
FROM website_sessions
WHERE created_at < '2014-11-01' 
      AND created_at >= '2014-01-01'
      AND is_repeat_session = 0
) AS new_sessions
LEFT JOIN website_sessions
     ON new_sessions.user_id = website_sessions.user_id AND
     website_sessions.is_repeat_session = 1 AND
     website_sessions.website_session_id > new_sessions.website_session_id AND
     website_sessions.created_at < '2014-11-01' 
      AND website_sessions.created_at >= '2014-01-01';
    
SELECT 
     repeat_sessions,
     COUNT(user_id) as users
FROM
(
SELECT 
     user_id,
     COUNT(DISTINCT new_session_id) as new_sessions,
     COUNT(DISTINCT repeat_session_id) as repeat_sessions
FROM sessions_w_repeats
GROUP BY 1
ORDER BY 3 DESC
) AS x
GROUP BY 1
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------

-- Could you help me understand the minimum, maximum, and average time between the first and second session for
-- customers who do come back? Again, analyzing 2014 to date is probably the right time period.

CREATE TEMPORARY TABLE users_info
SELECT 
     website_session_id,
     created_at,
     user_id,
     is_repeat_session,
     ROW_NUMBER() OVER (PARTITION BY user_id order by created_at) as row_num
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03'
ORDER BY user_id, created_at;

SELECT
    AVG(DATEDIFF(session2_datetime, session1_datetime)) AS avg_days_first_to_second,
    MIN(DATEDIFF(session2_datetime, session1_datetime)) AS min_days_first_to_second,
    MAX(DATEDIFF(session2_datetime, session1_datetime)) AS max_days_first_to_second
FROM
(
SELECT
	 user_id,
	 MIN(CASE WHEN row_num = 1 THEN created_at ELSE NULL END) as session1_datetime,
     MIN(CASE WHEN row_num = 2 THEN created_at ELSE NULL END) as session2_datetime
FROM users_info
GROUP BY user_id
) as x
WHERE session2_datetime is not null;

-----------------------------------------------------------------------------------------------------------------

-- Comparing new vs. repeat sessions by channel would be really valuable, 
-- if you’re able to pull it! 2014 to date is great.

SELECT 
     Channel_group,
     COUNT(new_session) as new_sessions,
     COUNT(repeat_session) as repeat_sessions
FROM
(
SELECT 
     website_session_id,
     created_at,
     user_id,
     is_repeat_session,
     CASE WHEN http_referer IS NULL THEN 'direct_type_in'
          WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN 'Organic_search' 
          WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
          WHEN utm_campaign = 'brand' THEN 'paid_brand'
          WHEN utm_source = 'socialbook' THEN 'paid_social'
          END as Channel_group,
	 CASE WHEN is_repeat_session = 0 THEN 'new_session' ELSE NULL END as new_session,
     CASE WHEN is_repeat_session = 1 THEN 'repeat_session' ELSE NULL END as repeat_session
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01'
      AND '2014-11-05'
) as x
GROUP BY 1
ORDER BY 3 DESC;

------------------------------------------------------------------------------------------------------------------

-- do a comparison of conversion rates and revenue per session for repeat sessions vs new sessions. 

SELECT 
     is_repeat_session,
     COUNT(DISTINCT ws.website_session_id) as sessions,
     COUNT(DISTINCT od.website_session_id)/
     COUNT(DISTINCT ws.website_session_id)*100 as session_to_orders_cnv_rate,
     SUM(price_usd)/
     COUNT(DISTINCT ws.website_session_id) as rev_per_session
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1;

-------------------------------------------------------------------------------------------------------------------------

-- Now that we’ve been in market for 3 years, we’ve generated enough growth to raise a much larger round of venture
-- capital funding. We’re close to securing a large round from one of the best West Coast firms.

-- Q1 First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter
-- for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.

SELECT 
     YEAR(ws.created_at) as Year,
	 QUARTER(ws.created_at) as Quarter,
     COUNT(DISTINCT ws.website_session_id) as sessions,
     COUNT(DISTINCT od.website_session_id) as orders
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
WHERE YEAR(ws.created_at) != '2015'
GROUP BY YEAR(ws.created_at),
         QUARTER(ws.created_at);
         
-- Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we
-- launched, for session-to-order conversion rate, revenue per order, and revenue per session. 

SELECT 
     YEAR(ws.created_at) as Year,
	 QUARTER(ws.created_at) as Quarter,
     COUNT(DISTINCT od.website_session_id)/
     COUNT(DISTINCT ws.website_session_id) as session_to_order_cnv_rate,
     SUM(price_usd)/
     COUNT(DISTINCT od.website_session_id) as revenue_per_order,
     SUM(price_usd)/
     COUNT(DISTINCT ws.website_session_id) as revenue_per_session
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
GROUP BY YEAR(ws.created_at),
         QUARTER(ws.created_at);
         
-- I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch
-- nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?


SELECT 
     YEAR(ws.created_at),
	 QUARTER(ws.created_at),
     COUNT(CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN 'gsearch_nonbrand' ELSE NULL END) AS gsearch,
	 COUNT(CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS bsearch,
	 COUNT(CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS brand,
	 COUNT(CASE WHEN utm_source is null AND http_referer is not null THEN order_id ELSE NULL END) as Organic,
     COUNT(CASE WHEN http_referer is null THEN order_id ELSE NULL END) AS direct
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
GROUP BY YEAR(ws.created_at),
         QUARTER(ws.created_at);
         
-- Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter.
-- Please also make a note of any periods where we made major improvements or optimizations.

SELECT 
     YEAR(ws.created_at) AS 'Year',
	 QUARTER(ws.created_at) AS 'Quarter',
     COUNT(CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_cnv_rate,
	 COUNT(CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_cnv_rate,
	 COUNT(CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_cnv_rate,
	 COUNT(CASE WHEN utm_source is null AND http_referer is not null THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN utm_source is null AND http_referer is not null THEN ws.website_session_id ELSE NULL END) as Organic_cnv_rate,
     COUNT(CASE WHEN http_referer is null THEN order_id ELSE NULL END)/
     COUNT(CASE WHEN http_referer is null THEN ws.website_session_id ELSE NULL END) AS direct_typein_cnv_rate
FROM website_sessions ws
LEFT JOIN orders od
ON ws.website_session_id = od.website_session_id
GROUP BY YEAR(ws.created_at),
	 QUARTER(ws.created_at);
     
---------------------------------------------------------------------------------------------------------------------

-- We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue
-- and margin by product, along with total sales and revenue. Note anything you notice about seasonality.

SELECT 
     YEAR(ot.created_at) as 'Year',
  	 MONTH(ot.created_at) as 'Month',
     SUM(CASE WHEN p.product_id = 1 THEN price_usd ELSE NULL END) as mr_fuzzy_rev,
     SUM(CASE WHEN p.product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) as mr_fuzzy_margin,
     SUM(CASE WHEN p.product_id = 2 THEN price_usd ELSE NULL END) as love_bear_rev,
     SUM(CASE WHEN p.product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) as love_bear_margin,
     SUM(CASE WHEN p.product_id = 3 THEN price_usd ELSE NULL END) as sugar_panda_rev,
     SUM(CASE WHEN p.product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) as sugar_panda_margin,
     SUM(CASE WHEN p.product_id = 4 THEN price_usd ELSE NULL END) as mini_bear_rev,
     SUM(CASE WHEN p.product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) as mini_bear_margin,
     SUM(price_usd) as Total_Revenue,
     SUM(price_usd - cogs_usd) as Total_Margin
FROM order_items ot
LEFT JOIN products p
ON ot.product_id = p.product_id
GROUP BY YEAR(ot.created_at),
  	 MONTH(ot.created_at);

-- Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products
-- page, and show how the % of those sessions clicking through another page has changed over time, along with
-- a view of how conversion from /products to placing an order has improved.

CREATE TEMPORARY TABLE product_pageviews
SELECT
	 website_session_id,
     website_pageview_id,
     created_at as saw_page_at
FROM website_pageviews
WHERE pageview_url = '/products';

SELECT
     YEAR(saw_page_at) as 'Year',
     MONTH(saw_page_at) as 'Month',
     COUNT(DISTINCT pp.website_session_id) as Session_to_Product_page,
     COUNT(DISTINCT wp.website_session_id) as Click_to_next_page,
     COUNT(DISTINCT wp.website_session_id)/
     COUNT(DISTINCT pp.website_session_id)*100 as clickthrough_rate,
     COUNT(DISTINCT order_id) as orders,
     COUNT(DISTINCT order_id)/COUNT(DISTINCT pp.website_session_id)*100	 as product_to_order
FROM product_pageviews pp
LEFT JOIN website_pageviews wp
ON wp.website_session_id = pp.website_session_id AND
   wp.website_pageview_id > pp.website_pageview_id
LEFT JOIN orders
ON orders.website_session_id = pp.website_session_id
GROUP BY 1,2;

-- We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell
-- item). Could you please pull sales data since then, and show how well each product cross-sells from one another?

CREATE TEMPORARY TABLE primary_products
SELECT
	 order_id,
     primary_product_id,
     created_at as Order_date
FROM orders
ORDER BY order_id;

SELECT
     primary_product_id,
     COUNT(order_id) as orders,
     COUNT(CASE WHEN product_id = 1 THEN order_id ELSE NULL END) AS product_1,
     COUNT(CASE WHEN product_id = 2 THEN order_id ELSE NULL END) AS product_2,
     COUNT(CASE WHEN product_id = 3 THEN order_id ELSE NULL END) AS product_3,
     COUNT(CASE WHEN product_id = 4 THEN order_id ELSE NULL END) AS product_3,
     COUNT(CASE WHEN product_id = 1 THEN order_id ELSE NULL END)/
     COUNT(order_id)*100 AS product1_cross_sell,
     COUNT(CASE WHEN product_id = 2 THEN order_id ELSE NULL END)/
     COUNT(order_id)*100 AS product2_cross_sell,
     COUNT(CASE WHEN product_id = 3 THEN order_id ELSE NULL END)/
     COUNT(order_id)*100 AS product3_cross_sell,
     COUNT(CASE WHEN product_id = 4 THEN order_id ELSE NULL END)/
     COUNT(order_id)*100 AS product4_cross_sell
FROM 
(
SELECT 
     pp.*,
     product_id
FROM primary_products pp
LEFT JOIN order_items ot
ON pp.order_id = ot.order_id
AND ot.is_primary_item = 0
) as x
GROUP BY 1
ORDER BY 1;        