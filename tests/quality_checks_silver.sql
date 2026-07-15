/*
***********************************************************
Quality checks
***********************************************************
Script purpose:
          This script performs various quality checks for data consistency ,
          accuracy, and standardization across the 'silver' schemas. It
          includes checks for :
          - NULL or duplicate priary keys.
          -unwanted spaces in string fields
          -Data standardizations and consistency
          -Invalid date ranges and orders
          _data consistency b/w related fields

Usage Notes:
          -Run these checks after loading silver layer
          -Investigate and resolve any discrepancies found during the checks 
***************************************************************
*/

-- ***********************************************************
-- checking 'silver.crm_cust_info'
-- ***********************************************************
-- Expectations : NO results

/*
	Check for NULL or Duplicates in Primary Key
	Expectation : No Result
*/

SELECT 
	cst_id,
	COUNT(*) AS Counting
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


/*
	Check for unwanted spaces
	Expectation : No Result
*/

SELECT 
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


/*
	Data Standardization & Consistency
*/

SELECT DISTINCT
	cst_gndr
FROM silver.crm_cust_info;



-- ***********************************************************
-- checking 'silver.crm_prd_info'
-- ***********************************************************
-- Expectations : NO results


------------------------------------------------------------
-- Check for NULL or Duplicate Primary Keys
-- Expectation: No Results
------------------------------------------------------------
SELECT
    prd_id,
    COUNT(*) AS Counting
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;

------------------------------------------------------------
-- Check for Unwanted Spaces
-- Expectation: No Results
------------------------------------------------------------
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

------------------------------------------------------------
-- Check for NULL or Negative Product Cost
-- Expectation: No Results
------------------------------------------------------------
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL
   OR prd_cost < 0;

------------------------------------------------------------
-- Check Data Standardization & Consistency
------------------------------------------------------------
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;

------------------------------------------------------------
-- Check for Invalid Date Ranges
-- Expectation: No Results
------------------------------------------------------------
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt IS NOT NULL
  AND prd_start_dt > prd_end_dt;



-- ***********************************************************
-- checking 'silver.crm_sales_details'
-- ***********************************************************
-- Expectations : NO results

------------------------------------------------------------
-- Check for Unwanted Spaces in Order Number
-- Expectation: No Results
------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num);

------------------------------------------------------------
-- Check for Invalid Customer References
-- Expectation: No Results
------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN
(
    SELECT cst_id
    FROM silver.crm_cust_info
);

------------------------------------------------------------
-- Check for Invalid Product References
-- Expectation: No Results
------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN
(
    SELECT prd_key
    FROM silver.crm_prd_info
);

------------------------------------------------------------
-- Check for Invalid Order Dates
-- Expectation: No Results
------------------------------------------------------------
SELECT
    sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
   OR sls_order_dt > '2050-01-01'
   OR sls_order_dt < '1900-01-01';

------------------------------------------------------------
-- Check Date Sequence
-- Expectation: No Results
------------------------------------------------------------
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

------------------------------------------------------------
-- Check Sales, Quantity and Price Consistency
-- Sales = Quantity × Price
-- Expectation: No Results
------------------------------------------------------------
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0;



-- ***********************************************************
-- checking 'silver.erp_cust_az12'
-- ***********************************************************
-- Expectations : NO results


------------------------------------------------------------
-- Check for Out-of-Range Birth Dates
-- Expectation: No Results
------------------------------------------------------------
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();

------------------------------------------------------------
-- Check Data Standardization & Consistency
------------------------------------------------------------
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- ***********************************************************
-- checking 'silver.erp_loc_a101'
-- ***********************************************************
-- Expectations : NO results

/*
------------------------------------------------------------
ERP Location Quality Checks
------------------------------------------------------------
*/

------------------------------------------------------------
-- Check for Invalid Customer References
-- Expectation: No Results
------------------------------------------------------------
SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN
(
    SELECT cst_key
    FROM silver.crm_cust_info
);

------------------------------------------------------------
-- Check Data Standardization & Consistency
------------------------------------------------------------
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101;



-- ***********************************************************
-- checking 'silver.erp_px_cat_g1v2'
-- ***********************************************************
-- Expectations : NO results

/*
------------------------------------------------------------
ERP Product Category Quality Checks
------------------------------------------------------------
*/

------------------------------------------------------------
-- Check for Invalid Product References
-- Expectation: No Results
------------------------------------------------------------
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM silver.erp_px_cat_g1v2
WHERE id NOT IN
(
    SELECT cat_id
    FROM silver.crm_prd_info
);

------------------------------------------------------------
-- Check for Unwanted Spaces
-- Expectation: No Results
------------------------------------------------------------
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);

------------------------------------------------------------
-- Check Data Standardization & Consistency
------------------------------------------------------------
SELECT DISTINCT
    cat,
    subcat,
    maintenance
FROM silver.erp_px_cat_g1v2;
