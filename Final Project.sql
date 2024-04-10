------------------------- MAVENFUZZY FACTORY ECOMMERCE AND WEBSITE ANALYSIS --------------------

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