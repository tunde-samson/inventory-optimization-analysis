# Phase 1: Data Exploration
##################################

use bokku_inventory;

select * from inventory;

select * from products;

select * from sales_transactions;

select * from stores;

select * from suppliers;

select * from warehouses;

# Phase 2: Sales by Product
##################################
# Business Question: Which products generate the most sales?

#1. Total Revenue by Product

SELECT 
    p.product_id,
    p.product_name,
    SUM(s.sales_amount) AS Total_Revenue
FROM
    products AS p
        JOIN
    sales_transactions AS s ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY Total_Revenue DESC;

#1. Total Quantity Sold

SELECT 
    p.product_id,
    p.product_name,
    SUM(s.quantity_sold) AS Total_Qty
FROM
    products AS p
        JOIN
    sales_transactions AS s ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY Total_Qty DESC;

#3. Top 10 Products (by sales)

SELECT 
    p.product_id,
    p.product_name,
    SUM(s.sales_amount) AS Total_Revenue
FROM
    products AS p
        JOIN
    sales_transactions AS s ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY Total_Revenue DESC
LIMIT 10;

# Phase 3: Sales by Store
##################################
# Business Question: Which stores perform best?

#1. Revenue by Store

SELECT 
    st.store_id,
    st.branch_name,
    SUM(s.sales_amount) AS Store_Sales
FROM
    stores AS st
        JOIN
    sales_transactions AS s ON st.store_id = s.store_id
GROUP BY st.branch_name
ORDER BY Store_Sales DESC;

#2. Unit sold by store

SELECT 
    st.store_id,
    st.branch_name,
    SUM(s.quantity_sold) AS Store_Sales
FROM
    stores AS st
        JOIN
    sales_transactions AS s ON st.store_id = s.store_id
GROUP BY st.branch_name
ORDER BY Store_Sales DESC;

#3. Monthly Sales by Stores

SELECT 
    st.store_id,
    st.branch_name,
    YEAR(s.transaction_date) AS Sales_Year,
    MONTH(s.transaction_date) AS Months_Number,
    MONTHNAME(s.transaction_date) AS Months,
    SUM(s.sales_amount) AS Monthly_Total_Sales
FROM
    stores AS st
        JOIN
    sales_transactions AS s ON st.store_id = s.store_id
GROUP BY 2 , 4
ORDER BY 6 DESC;

# Phase 4: Inventory Levels
################################
# Business Question: What inventory is available right now?

#1. Inventory by Product

SELECT 
    p.product_id,
    p.product_name,
    SUM(i.current_stock) AS Total_Stock
FROM
    products AS p
        JOIN
    inventory AS i ON p.product_id = i.product_id
GROUP BY 2
ORDER BY Total_Stock DESC;

#2. Products below reorder point

SELECT 
    p.product_id,
    p.product_name,
    i.current_stock,
    i.reorder_level
FROM
    products AS p
        JOIN
    inventory AS i
WHERE
    i.current_stock < i.reorder_level
ORDER BY i.current_stock;

#3. Inventory Value by Product

SELECT 
    p.product_id,
    p.product_name,
    SUM(i.current_stock * p.unit_price_ngn) AS Inventory_Value
FROM
    products AS p
        JOIN
    inventory AS i ON p.product_id = i.product_id
GROUP BY 2
ORDER BY 3 DESC;

# Phase 5: Supplier Performance
####################################
# Business Question: Which suppliers are supporting inventory effectively?

#1. Number of Products per Supplier

SELECT 
    su.supplier_name, COUNT(p.product_name) AS Product_Count
FROM
    products AS p
        JOIN
    suppliers AS su ON p.supplier_id = su.supplier_id
GROUP BY 1
ORDER BY 2 DESC;

#2. Supplier Revenue Contribution

SELECT 
    su.supplier_name,
    SUM(s.quantity_sold * p.unit_price_ngn) AS Supplier_Contribution
FROM
    suppliers AS su
        JOIN
    products AS p ON su.supplier_id = p.supplier_id
        JOIN
    sales_transactions AS s ON p.product_id = s.product_id
GROUP BY 1
ORDER BY 2 DESC;

#3. Average Supplier Lead Time

SELECT 
    supplier_name, AVG(lead_time_days) AS Supplier_AVG_Lead_Time
FROM
    suppliers
GROUP BY 1
ORDER BY 2 DESC;

#Phase 6: Create SQL Views

# create view for product sales summary

CREATE VIEW Product_Sales_Summary AS
    SELECT 
        p.product_id,
        p.product_name,
        SUM(s.quantity_sold) AS Total_Qty,
        SUM(s.sales_amount) AS Total_Sales
    FROM
        products AS p
            JOIN
        sales_transactions AS s ON p.product_id = s.product_id
    GROUP BY 2
    ORDER BY 4 DESC;
    
select * from Product_sales_summary;

# Create View for Store Performance

CREATE VIEW Store_performance AS
    SELECT 
        st.store_id,
        st.branch_name,
        SUM(s.quantity_sold) AS Total_Qty,
        SUM(s.sales_amount) AS Total_Sales
    FROM
        stores AS st
            JOIN
        sales_transactions AS s ON st.store_id = s.store_id
    GROUP BY 2
    ORDER BY 4 DESC;
    
    select * from Store_performance;
    
    # create view inventory status
    
    CREATE VIEW inventory_status AS
    SELECT 
        p.product_id,
        p.product_name,
        i.current_stock,
        i.reorder_level
    FROM
        products AS p
            JOIN
        inventory AS i ON p.product_id = i.product_id
    WHERE
        i.current_stock < i.reorder_level
    ORDER BY i.current_stock;
    
    select * from inventory_status;
    
    #create view supplier performance
    
    CREATE VIEW supplier_performance AS
    SELECT 
        su.supplier_id,
        su.supplier_name,
        su.lead_time_days,
        SUM(s.quantity_sold * p.unit_price_ngn) AS Total_Sales
    FROM
        suppliers AS su
            JOIN
        products AS p ON su.supplier_id = p.supplier_id
            JOIN
        sales_transactions AS s ON p.product_id = s.product_id
    GROUP BY 2
    ORDER BY 4 DESC;
    
    SELECT * from supplier_performance;
    
    #Create view for monthly sales Trend
    
    CREATE VIEW monthly_sales_trend AS
    SELECT 
        p.product_name,
        YEAR(s.transaction_date) AS Sales_Year,
        MONTHNAME(s.transaction_date) AS Sales_Month,
        MONTH(s.transaction_date) AS Sales_Month_Number,
        SUM(s.sales_amount) AS Monthly_Sales
    FROM
        products AS p
            JOIN
        sales_transactions AS s ON p.product_id = s.product_id
    GROUP BY 1
    ORDER BY 5 DESC;
    
    select * from monthly_sales_trend;
    
    








