# HNG Data Project: Sales Dashboard and Banking Data Model

This project has two parts, completed during the HNG Internship in May 2026. Part A is a Power BI sales and operations analysis. Part B is a star schema design for retail banking analytics in PostgreSQL.

> **Note:** This is an early project. I have kept it close to the original version to show my starting point as I transition into data analysis. See each part's "Limitations" section.

---

## Part A: Northwind Sales and Operations Dashboard (Power BI)

**Folder:** `part-a-northwind-powerbi/`

### Dataset
The public Northwind sample dataset: 830 orders, plus customers, employees, products, categories, and shippers. The CSV files are Latin-1 encoded.

### What I built
- A three-page Power BI dashboard (`Task_A.pbix`) with custom measures for total revenue, total orders, average order value and average shipping days
- An executive report (PDF) with findings and recommendations

### Key findings
- Revenue of $1,265,793 from 830 orders (average order value $1,525.05) 
- April 2015 was the highest revenue month (about $123.8K)
- Beverages, Dairy Products and Confections are the top three categories
- Federal Shipping is fastest (about 7.5 days to ship), United Package slowest (about 9.2 days)
- Orders to Austria and Ireland have the highest average freight costs
- The USA, Germany and Austria are the top three countries by revenue
- Margaret Peacock is the top salesperson by revenue

### Limitations (and what I'd do differently)
- The discontinued-products figure in the report (9.6%) does not match my recalculation from the CSVs (about 14.6%). I would recheck the measure.
- The last month (May 2015) is incomplete, which causes the sharp drop at the end of the revenue chart.
- "Shipping days" is order-to-shipped time. The dataset has no delivery date.
- There is no cost data, so statements about profitability are based on revenue only.
- Some conclusions (seasonality, discount effects) rest on limited data and should be treated as indicative.

---

## Part B: Palladium Bank Star Schema (PostgreSQL)

**Folder:** `part-b-palladium-star-schema/`

### What I built
- A star schema for retail banking analytics: one fact table (`FactTransactions`) and four dimensions (`DimDate`, `DimCustomer`, `DimBranch`, `DimProduct`), with surrogate keys and foreign keys
- An SCD Type 2 design for the customer dimension, to track tier changes
- A written explanation of the design (`docs/WRITTEN_EXPLANATION.pdf`)
- An ER diagram (`images/Schema_Diagram.png`)

### Data
A sample of 10 transactions from 8 January 2024 across 7 customers, 6 branches and 8 products. The raw file and the dimension and fact load files are in `data/`.

### Limitations (and what I'd do differently)
- `Palladium_Bank.sql` is my original script. Its dimension inserts do not fully match the source data, so 4 of the 10 transactions would join to the wrong customer, branch or product if it is run as is. The CSV files in `data/` (the `*_Load.csv` files) are the correct, validated versions.
- The data is a 10-transaction sample from one day, not 18 months of history. The design is intended to scale to that volume.
- SCD Type 2 is built into the customer table, but the sample has no tier changes, so it is not demonstrated. The start date (2023-01-01) is an assumption.
- Data quality checks, indexing and partitioning are described in the written explanation as the planned approach. They are not implemented in the script. `Txn_ID` has no unique constraint yet.
- Next time I would build the dimension keys from the source data instead of typing them in, and test the load with a validation query.

---

## Repository Structure
- `part-a-northwind-powerbi/`: dashboard, report, data, screenshots
- `part-b-palladium-star-schema/`: SQL script, data, written explanation,
  schema diagram

## Author
Rukky Ujara | https://www.linkedin.com/in/rhukhi/ | rukkyujara@gmail.com
