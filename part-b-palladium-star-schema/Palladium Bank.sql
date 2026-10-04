/* PALLADIUM BANK - RETAIL BANKING ANALYTICS STAGING & STAR SCHEMA  */

-- =============================================
-- 1. DATABASE CREATION
-- =============================================
CREATE DATABASE palladium_retail_analytics;
-- \c palladium_retail_analytics;

-- =============================================
-- 2. DIMENSION TABLE SCHEMA (The "Parents")
-- =============================================

-- DimDate: Time-based analysis
CREATE TABLE DimDate (
    Date_SK INT PRIMARY KEY,
    Full_Date DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month_Name VARCHAR(20) NOT NULL,
    Month_Number INT NOT NULL,
    Day_of_Week VARCHAR(20) NOT NULL,
    Is_Weekend BOOLEAN
);

-- DimCustomer: SCD Type 2 for tracking tier changes
CREATE TABLE DimCustomer (
    Customer_SK SERIAL PRIMARY KEY,
    Customer_ID VARCHAR(50) NOT NULL,
    Customer_Name VARCHAR(100) NOT NULL,
    Tier VARCHAR(20),
    Start_Date DATE NOT NULL,
    End_Date DATE,
    Is_Current BOOLEAN DEFAULT TRUE
);

-- DimBranch: Geographical attributes
CREATE TABLE DimBranch (
    Branch_SK SERIAL PRIMARY KEY,
    Branch_ID VARCHAR(50) NOT NULL,
    Branch_Name VARCHAR(100) NOT NULL,
    State VARCHAR(50) NOT NULL
);

-- DimProduct: Banking services
CREATE TABLE DimProduct (
    Product_SK SERIAL PRIMARY KEY,
    Product_ID VARCHAR(50) NOT NULL,
    Product_Name VARCHAR(100) NOT NULL,
    Product_Type VARCHAR(50) NOT NULL
);

-- =============================================
-- 3. FACT TABLE SCHEMA (The "Child")
-- =============================================

CREATE TABLE FactTransactions (
    Transaction_SK SERIAL PRIMARY KEY,
    Txn_ID VARCHAR(50) NOT NULL,
    Date_SK INT NOT NULL,
    Customer_SK INT NOT NULL,
    Branch_SK INT NOT NULL,
    Product_SK INT NOT NULL,
    Txn_Type VARCHAR(50),
    Channel VARCHAR(50),
    Amount_Naira NUMERIC(18, 2),
    Balance_After_Naira NUMERIC(18, 2),
    
    CONSTRAINT fk_date FOREIGN KEY (Date_SK) REFERENCES DimDate(Date_SK),
    CONSTRAINT fk_customer FOREIGN KEY (Customer_SK) REFERENCES DimCustomer(Customer_SK),
    CONSTRAINT fk_branch FOREIGN KEY (Branch_SK) REFERENCES DimBranch(Branch_SK),
    CONSTRAINT fk_product FOREIGN KEY (Product_SK) REFERENCES DimProduct(Product_SK)
);

-- =============================================
-- 4. DATA POPULATION (Dimensions)
-- =============================================

-- Populate DimDate (2024 Calendar)
INSERT INTO DimDate (Date_SK, Full_Date, Year, Quarter, Month_Name, Month_Number, Day_of_Week, Is_Weekend)
SELECT 
    CAST(to_char(d, 'YYYYMMDD') AS INT) AS Date_SK,
    d::date AS Full_Date,
    EXTRACT(YEAR FROM d) AS Year,
    EXTRACT(QUARTER FROM d) AS Quarter,
    to_char(d, 'Month') AS Month_Name,
    EXTRACT(MONTH FROM d) AS Month_Number,
    to_char(d, 'Day') AS Day_of_Week,
    CASE WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE ELSE FALSE END AS Is_Weekend
FROM generate_series('2024-01-01'::date, '2024-12-31'::date, '1 day'::interval) d;

-- Populate DimProduct
INSERT INTO DimProduct (Product_ID, Product_Name, Product_Type)
VALUES 
('P007', 'Debit Card', 'Card'), ('P002', 'Savings Account', 'Account'),
('P009', 'Mobile Banking', 'Digital'), ('P001', 'Current Account', 'Account'),
('P004', 'Personal Loan', 'Loan'), ('P005', 'Fixed Deposit', 'Account'),
('P008', 'Credit Card', 'Card'), ('P003', 'Business Account', 'Account');

-- Populate DimCustomer
INSERT INTO DimCustomer (Customer_ID, Customer_Name, Tier, Start_Date, Is_Current)
VALUES 
('C0001', 'Emeka Yakubu', 'Platinum', '2023-01-01', TRUE),
('C0003', 'Funke Nwosu', 'Silver', '2023-01-01', TRUE),
('C0004', 'Fatima Ibrahim', 'Standard', '2023-01-01', TRUE),
('C0005', 'Gbenga Ibrahim', 'Platinum', '2023-01-01', TRUE),
('C0002', 'Chidi Okafor', 'Gold', '2023-01-01', TRUE),
('C0007', 'Amina Bello', 'Silver', '2023-01-01', TRUE),
('C0006', 'Zainab Aliyu', 'Gold', '2023-01-01', TRUE);

-- Populate DimBranch
INSERT INTO DimBranch (Branch_ID, Branch_Name, State)
VALUES 
('B02', 'Ikeja', 'Lagos'), ('B04', 'Abuja Central', 'Abuja'),
('B01', 'Lagos Island', 'Lagos'), ('B03', 'Port Harcourt', 'Rivers'),
('B05', 'Kano City', 'Kano'), ('B06', 'Ibadan North', 'Oyo');

-- =============================================
-- 5. DATA POPULATION (Fact Table)
-- =============================================

INSERT INTO FactTransactions (Txn_ID, Date_SK, Customer_SK, Branch_SK, Product_SK, Txn_Type, Channel, Amount_Naira, Balance_After_Naira)
VALUES 
('TXN-10041', 20240108, 1, 1, 1, 'POS Purchase', 'POS', 45000.00, 1820450.00),
('TXN-10042', 20240108, 2, 1, 2, 'Deposit', 'Branch', 120000.00, 534210.50),
('TXN-10043', 20240108, 3, 2, 3, 'Bill Payment', 'Mobile App', 18500.00, 62100.00),
('TXN-10044', 20240108, 1, 1, 4, 'Transfer', 'Internet Banking', 500000.00, 1320450.00),
('TXN-10045', 20240108, 4, 3, 5, 'Loan Repayment', 'Branch', 250000.00, 0.00),
('TXN-10046', 20240108, 5, 4, 6, 'Interest Credit', 'System', 12450.75, 2450800.00),
('TXN-10047', 20240108, 2, 1, 1, 'ATM Withdrawal', 'ATM', 20000.00, 514210.50),
('TXN-10048', 20240108, 6, 5, 2, 'Withdrawal', 'USSD', 15000.00, 48700.00),
('TXN-10049', 20240108, 7, 6, 7, 'Card Issuance', 'Branch', 5000.00, 112400.00),
('TXN-10050', 20240108, 5, 4, 8, 'Corporate Transfer', 'Internet Banking', 1200000.00, 1250800.00);

-- =============================================
-- 6. FINAL VALIDATION QUERY
-- =============================================

SELECT 
    c.Customer_Name, 
    c.Tier, 
    b.Branch_Name, 
    f.Amount_Naira, 
    f.Txn_Type
FROM FactTransactions f
JOIN DimCustomer c ON f.Customer_SK = c.Customer_SK
JOIN DimBranch b ON f.Branch_SK = b.Branch_SK;