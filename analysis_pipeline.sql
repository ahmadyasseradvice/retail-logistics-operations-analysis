/* =====================================================================
   PROJECT: Retail Logistics & Order Turnaround Pipeline
   AUTHOR: Ahmad Yasser Morsy
   PURPOSE: Analyze shipping durations, SLA delivery variances,
            and corridor-level delivery bottlenecks.
   ===================================================================== */

-- STEP 1: Consolidate core order line-items and calculate delivery turnaround times.
WITH Order_Turnaround_Base AS (
    SELECT 
        o.order_id,
        o.customer_id,
        c.customer_state,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        
        -- Calculate actual transit duration in days
        ROUND(
            JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp), 
            1
        ) AS actual_transit_days,
        
        -- Delivery Variance: Positive = Delayed, Negative = Early/On-Time
        ROUND(
            JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_estimated_delivery_date), 
            1
        ) AS delay_variance_days,
        
        -- Categorize delivery status for business reporting
        CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delayed'
            WHEN o.order_delivered_customer_date IS NULL THEN 'In-Transit / Unfulfilled'
            ELSE 'On-Time / Early'
        END AS fulfillment_status

    FROM orders o
    INNER JOIN customers c 
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
),

-- STEP 2: Aggregate customer-level frequency and state-level rank.
Customer_Order_History AS (
    SELECT 
        ot.customer_id,
        ot.customer_state,
        COUNT(ot.order_id) AS total_orders,
        AVG(ot.actual_transit_days) AS avg_transit_days_per_customer,
        SUM(CASE WHEN ot.fulfillment_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_orders_experienced,
        
        -- Rank customers by transaction volume within their respective state
        DENSE_RANK() OVER (
            PARTITION BY ot.customer_state 
            ORDER BY COUNT(ot.order_id) DESC
        ) AS state_customer_rank

    FROM Order_Turnaround_Base ot
    GROUP BY ot.customer_id, ot.customer_state
),

-- STEP 3: Identify shipping corridors with systemic delivery bottlenecks.
Corridor_Delay_Analysis AS (
    SELECT 
        customer_state,
        COUNT(order_id) AS total_shipments,
        ROUND(AVG(actual_transit_days), 2) AS mean_transit_days,
        ROUND(AVG(delay_variance_days), 2) AS mean_delay_variance,
        ROUND(
            100.0 * SUM(CASE WHEN fulfillment_status = 'Delayed' THEN 1 ELSE 0 END) / COUNT(order_id), 
            2
        ) AS delay_rate_percentage
    FROM Order_Turnaround_Base
    GROUP BY customer_state
    HAVING COUNT(order_id) >= 500
)

-- FINAL REPORT QUERY: Categorize routes by SLA risk tier.
SELECT 
    cda.customer_state,
    cda.total_shipments,
    cda.mean_transit_days,
    cda.mean_delay_variance,
    cda.delay_rate_percentage,
    CASE 
        WHEN cda.delay_rate_percentage >= 15.0 THEN 'Critical Attention - SLA Breach Risk'
        WHEN cda.delay_rate_percentage >= 8.0  THEN 'Moderate Delay - Route Optimization Needed'
        ELSE 'Healthy Route Performance'
    END AS operational_sla_tier
FROM Corridor_Delay_Analysis cda
ORDER BY cda.delay_rate_percentage DESC;
