--------------Creating the Baseline---------
------For a baseline, we assume that comoany is generating the same revenue as last month, we can take 3 month average or last 6 month average as baseline---


SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Partner_Fee + Revenue AS BaseLine
	FROM
		(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
		SUM(Revenue) AS Revenue,
		SUM(Partner_Fee) AS Partner_Fee,
		SUM(Registration_Fee) AS Registration_Fee
		FROM
		(SELECT StoreNo AS Account_No, 
				[Month] AS Fiscal_Month, 
				Revenue_Type, Revenue_Motion, Product_Category, 
				Motion AS Account_Motion,
		CASE	
			WHEN Product_Category LIKE '%Product%' THEN 'Products'
			WHEN Product_Category LIKE '%Service%' THEN 'Services'
			WHEN Product_Category LIKE '%Support%' THEN 'Support'
			ELSE 'Need Mapping'
			END AS Product_Category_2,
		IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
		IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
		IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
		FROM Revenue_File_Wk25) a

		GROUP BY Account_No, Fiscal_Month, Product_Category_2
		)a

		LEFT JOIN

	(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
	ON a.Fiscal_Month = b.Date_Value
	WHERE a. Fiscal_Month = 'January, 2019'


	-------THIS IS MANUAL PROCESS AND WE HAVE TO CHANGE MONTH EACH TIME, SO LETS AUTOMATE THIS-------

SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, a.Baseline

FROM

	(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Partner_Fee + Revenue AS BaseLine
		FROM
			(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
			SUM(Revenue) AS Revenue,
			SUM(Partner_Fee) AS Partner_Fee,
			SUM(Registration_Fee) AS Registration_Fee
			FROM
			(SELECT StoreNo AS Account_No, 
					[Month] AS Fiscal_Month, 
					Revenue_Type, Revenue_Motion, Product_Category, 
					Motion AS Account_Motion,
			CASE	
				WHEN Product_Category LIKE '%Product%' THEN 'Products'
				WHEN Product_Category LIKE '%Service%' THEN 'Services'
				WHEN Product_Category LIKE '%Support%' THEN 'Support'
				ELSE 'Need Mapping'
				END AS Product_Category_2,
			IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
			IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
			IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
			FROM Revenue_File_Wk25) a

			GROUP BY Account_No, Fiscal_Month, Product_Category_2
			)a

		LEFT JOIN

	(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
	ON a.Fiscal_Month = b.Date_Value
	WHERE a. Fiscal_Month = (SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
	)a

CROSS JOIN


	(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
	(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
	(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
	)b



	----------------------------------Cleaning Target Table-----------
SELECT * FROM Business_Targets1

SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, A.[Target]

FROM

(SELECT Store_Number AS Account_no, Service_Comp_Group AS Product_Category, Fiscal_Month, [Target]
FROM Business_Targets1)a

LEFT JOIN

(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
ON a.Fiscal_Month = b.Date_Value




------------------JOINING Cleaned Target VIEW with BAseline------------------------------------------------------

SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS FIscal_Month,
ISNULL(Baseline, 0) AS Baseline,
ISNULL([Target], 0) AS [Target]

FROM
----This is baseline view
	(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, a.Baseline

	FROM

		(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Partner_Fee + Revenue AS BaseLine
			FROM
				(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
				SUM(Revenue) AS Revenue,
				SUM(Partner_Fee) AS Partner_Fee,
				SUM(Registration_Fee) AS Registration_Fee
				FROM
				(SELECT StoreNo AS Account_No, 
						[Month] AS Fiscal_Month, 
						Revenue_Type, Revenue_Motion, Product_Category, 
						Motion AS Account_Motion,
				CASE	
					WHEN Product_Category LIKE '%Product%' THEN 'Products'
					WHEN Product_Category LIKE '%Service%' THEN 'Services'
					WHEN Product_Category LIKE '%Support%' THEN 'Support'
					ELSE 'Need Mapping'
					END AS Product_Category_2,
				IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
				IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
				IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
				FROM Revenue_File_Wk25) a

				GROUP BY Account_No, Fiscal_Month, Product_Category_2
				)a

			LEFT JOIN

		(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
		ON a.Fiscal_Month = b.Date_Value
		WHERE a. Fiscal_Month = (SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
		)a

	CROSS JOIN


		(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
		(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
		(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
		)b
	)a

FULL JOIN
------This is Target View-----joining both
	(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, A.[Target]

	FROM

	(SELECT Store_Number AS Account_no, Service_Comp_Group AS Product_Category, Fiscal_Month, [Target]
	FROM Business_Targets1)a

	LEFT JOIN

	(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
	ON a.Fiscal_Month = b.Date_Value
	)b
ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.Fiscal_Month = b.Fiscal_Month


---------------------------------OPPORTUNITY IN TO RUN RATE------------------



SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, 
IIF (Opportunity_Usage <0, 0, Opportunity_Usage) AS Opportunity_INTO_Runrate

FROM

	(SELECT a.*, b.Fiscal_Month AS Future_Fiscal_Months, b.Month_ID+1 AS Est_Month_ID

	FROM

		(
		----This is Opportunity Extrapulation data-----------

		 SELECT a.*,
			IIF(Opportunity_Usage <0, 0, Extrap_Month_Left_ForFY* Opportunity_Usage) AS Opportunities_extrapulation
			FROM
				(SELECT a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID,
				SUM(a.Opportunity_Usage) AS Opportunity_Usage,
				CASE
					WHEN Fiscal_Month LIKE '%July%' THEN 11
					WHEN Fiscal_Month LIKE '%August%' THEN 10
					WHEN Fiscal_Month LIKE '%September%' THEN 9
					WHEN Fiscal_Month LIKE '%October%' THEN 8
					WHEN Fiscal_Month LIKE '%November%' THEN 7
					WHEN Fiscal_Month LIKE '%December%' THEN 6
					WHEN Fiscal_Month LIKE '%January%' THEN 5
					WHEN Fiscal_Month LIKE '%February%' THEN 4
					WHEN Fiscal_Month LIKE '%March%' THEN 3
					WHEN Fiscal_Month LIKE '%April%' THEN 2
					WHEN Fiscal_Month LIKE '%May%' THEN 1
					WHEN Fiscal_Month LIKE '%June%' THEN 0
					END AS Extrap_Month_Left_ForFY
				FROM 

					(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID,
					SUM(CAST(IIF(Opportunity_Usage = 'NULL', 0, Opportunity_Usage) AS FLOAT)) AS Opportunity_Usage

					FROM

					(SELECT Store_No AS Account_No, Opportunity_Est_Date, Product,
					CASE	
						WHEN Product LIKE '%Products%' OR Product LIKE '%Product%' THEN 'Products'
						WHEN Product LIKE '%Service%' THEN 'Services'
						WHEN Product LIKE '%Support%' THEN 'Support'
						ELSE 'Need Mapping'
						END AS Product_Category,
						Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Usage, Opportunity_Stage  
					FROM Opportunities_Wk25
					WHERE Product IS NOT NULL AND Product <> 'NULL' AND Project_Status <> 'Inactive'
					)a

					LEFT JOIN

					(SELECT DISTINCT Date_Value, Fiscal_Month, Fiscal_Year, Month_ID FROM Calendar_Lookup)b

					ON a.Opportunity_Est_Date = b.Date_Value

					WHERE
					a.Opportunity_Est_Date > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND
					b.Fiscal_Year = (SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
					GROUP BY a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID)a
			
					GROUP BY a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID
			)a 
		)a

		CROSS JOIN


			(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
			(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
			(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
			)b

		WHERE a.Month_ID <= b.Month_ID
		)a


		LEFT JOIN

		(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup
		)b

		ON a.Est_Month_ID = b.Month_ID




--------------------------BRINGING ALL THE DATA TOGETHER----------------------------
---1.Opportunities and Revenue FULL JOIN-----------
---2.-BAseline and Target Full Join------------
---3. Opportunities into RUNRATE-------

--------Baseline and Target JOINED Opportunity INTO Run Rate----
SELECT  ISNULL(a.Account_No, b.Account_No) AS Account_No,
	ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
	ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS FIscal_Month,
	ISNULL(Baseline, 0) AS Baseline,
	ISNULL([Target], 0) AS [Target],
	ISNULL(Opportunity_INTO_Runrate, 0) AS Opportunity_INTO_Runrate

FROM

	(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
	ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
	ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS FIscal_Month,
	ISNULL(Baseline, 0) AS Baseline,
	ISNULL([Target], 0) AS [Target]

	FROM
	----This is baseline view
		(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, a.Baseline

		FROM

			(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Partner_Fee + Revenue AS BaseLine
				FROM
					(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
					SUM(Revenue) AS Revenue,
					SUM(Partner_Fee) AS Partner_Fee,
					SUM(Registration_Fee) AS Registration_Fee
					FROM
					(SELECT StoreNo AS Account_No, 
							[Month] AS Fiscal_Month, 
							Revenue_Type, Revenue_Motion, Product_Category, 
							Motion AS Account_Motion,
					CASE	
						WHEN Product_Category LIKE '%Product%' THEN 'Products'
						WHEN Product_Category LIKE '%Service%' THEN 'Services'
						WHEN Product_Category LIKE '%Support%' THEN 'Support'
						ELSE 'Need Mapping'
						END AS Product_Category_2,
					IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
					IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
					IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
					FROM Revenue_File_Wk25) a

					GROUP BY Account_No, Fiscal_Month, Product_Category_2
					)a

				LEFT JOIN

			(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
			ON a.Fiscal_Month = b.Date_Value
			WHERE a. Fiscal_Month = (SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
			)a

		CROSS JOIN


			(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
			(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
			(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
			)b
		)a

	FULL JOIN
	------This is Target View-----joining both

		(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, A.[Target]

		FROM

		(SELECT Store_Number AS Account_no, Service_Comp_Group AS Product_Category, Fiscal_Month, [Target]
		FROM Business_Targets1)a

		LEFT JOIN

		(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
		ON a.Fiscal_Month = b.Date_Value
		)b
	ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.Fiscal_Month = b.Fiscal_Month
	)a


FULL JOIN

	(
	-----THIS IS Opportunity IN RR TABLE--

	SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, 
	IIF (Opportunity_Usage <0, 0, Opportunity_Usage) AS Opportunity_INTO_Runrate

	FROM

		(SELECT a.*, b.Fiscal_Month AS Future_Fiscal_Months, b.Month_ID+1 AS Est_Month_ID

		FROM

			(
			----This is Opportunity Extrapulation data-----------

			 SELECT a.*,
				IIF(Opportunity_Usage <0, 0, Extrap_Month_Left_ForFY* Opportunity_Usage) AS Opportunities_extrapulation
				FROM
					(SELECT a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID,
					SUM(a.Opportunity_Usage) AS Opportunity_Usage,
					CASE
						WHEN Fiscal_Month LIKE '%July%' THEN 11
						WHEN Fiscal_Month LIKE '%August%' THEN 10
						WHEN Fiscal_Month LIKE '%September%' THEN 9
						WHEN Fiscal_Month LIKE '%October%' THEN 8
						WHEN Fiscal_Month LIKE '%November%' THEN 7
						WHEN Fiscal_Month LIKE '%December%' THEN 6
						WHEN Fiscal_Month LIKE '%January%' THEN 5
						WHEN Fiscal_Month LIKE '%February%' THEN 4
						WHEN Fiscal_Month LIKE '%March%' THEN 3
						WHEN Fiscal_Month LIKE '%April%' THEN 2
						WHEN Fiscal_Month LIKE '%May%' THEN 1
						WHEN Fiscal_Month LIKE '%June%' THEN 0
						END AS Extrap_Month_Left_ForFY
					FROM 

						(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID,
						SUM(CAST(IIF(Opportunity_Usage = 'NULL', 0, Opportunity_Usage) AS FLOAT)) AS Opportunity_Usage

						FROM

						(SELECT Store_No AS Account_No, Opportunity_Est_Date, Product,
						CASE	
							WHEN Product LIKE '%Products%' OR Product LIKE '%Product%' THEN 'Products'
							WHEN Product LIKE '%Service%' THEN 'Services'
							WHEN Product LIKE '%Support%' THEN 'Support'
							ELSE 'Need Mapping'
							END AS Product_Category,
							Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Usage, Opportunity_Stage  
						FROM Opportunities_Wk25
						WHERE Product IS NOT NULL AND Product <> 'NULL' AND Project_Status <> 'Inactive'
						)a

						LEFT JOIN

						(SELECT DISTINCT Date_Value, Fiscal_Month, Fiscal_Year, Month_ID FROM Calendar_Lookup)b

						ON a.Opportunity_Est_Date = b.Date_Value

						WHERE
						a.Opportunity_Est_Date > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND
						b.Fiscal_Year = (SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
						GROUP BY a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID)a
			
						GROUP BY a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID
				)a 
			)a

			CROSS JOIN


				(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
				(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
				(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
				)b

			WHERE a.Month_ID <= b.Month_ID
			)a


			LEFT JOIN

			(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup
			)b

			ON a.Est_Month_ID = b.Month_ID

	)b
	ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.FIscal_Month = b.Fiscal_Month


	---------JOINING ALL THE TABLES--------------



SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
	ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS Fiscal_Month,
	ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
	ISNULL(a. Revenue, 0) AS Revenue,
	ISNULL(a. Partner_Fee, 0) AS Partner_Fee,
	ISNULL(a. Registration_Fee, 0) AS Registration_Fee,
	ISNULL(a.Opportunity_Usage, 0) AS Opportunity_Usage,
	ISNULL(a.Opportunities_extrapulation, 0) AS Opportunities_Extrapulation,
	ISNULL(b. Baseline, 0) AS Baseline,
	ISNULL(b.[Target], 0) AS [Target],
	ISNULL(b.Opportunity_INTO_Runrate, 0) AS Opportunity_INTO_Runrate

	FROM


	(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
	ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS Fiscal_Month,
	ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
	ISNULL(Revenue, 0) AS Revenue,
	ISNULL(Partner_Fee, 0) AS Partner_Fee,
	ISNULL(Registration_Fee, 0) AS Registration_Fee,
	ISNULL(Opportunity_Usage, 0) AS Opportunity_Usage,
	ISNULL(Opportunities_extrapulation, 0) AS Opportunities_Extrapulation

	FROM
		------Revenue Table---
		(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Revenue, Partner_Fee, Registration_Fee
		FROM
			(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
			SUM(Revenue) AS Revenue,
			SUM(Partner_Fee) AS Partner_Fee,
			SUM(Registration_Fee) AS Registration_Fee
			FROM
			(SELECT StoreNo AS Account_No, 
					[Month] AS Fiscal_Month, 
					Revenue_Type, Revenue_Motion, Product_Category, 
					Motion AS Account_Motion,
			CASE	
				WHEN Product_Category LIKE '%Product%' THEN 'Products'
				WHEN Product_Category LIKE '%Service%' THEN 'Services'
				WHEN Product_Category LIKE '%Support%' THEN 'Support'
				ELSE 'Need Mapping'
				END AS Product_Category_2,
			IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
			IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
			IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
			FROM Revenue_File_Wk25) a

			GROUP BY Account_No, Fiscal_Month, Product_Category_2
			)a

		LEFT JOIN

		(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
		ON a.Fiscal_Month = b.Date_Value
		)a



	-----Account No, Product Category, Fiscal_Month	We will FULL join on these columns-----
	
	FULL JOIN
	
	---------This is Opportunity Extrabulation--------	
		(SELECT a.*,
		IIF(Opportunity_Usage <0, 0, Extrap_Month_Left_ForFY* Opportunity_Usage) AS Opportunities_extrapulation
		FROM
			(SELECT a.*,
			CASE
				WHEN Fiscal_Month LIKE '%July%' THEN 11
				WHEN Fiscal_Month LIKE '%August%' THEN 10
				WHEN Fiscal_Month LIKE '%September%' THEN 9
				WHEN Fiscal_Month LIKE '%October%' THEN 8
				WHEN Fiscal_Month LIKE '%November%' THEN 7
				WHEN Fiscal_Month LIKE '%December%' THEN 6
				WHEN Fiscal_Month LIKE '%January%' THEN 5
				WHEN Fiscal_Month LIKE '%February%' THEN 4
				WHEN Fiscal_Month LIKE '%March%' THEN 3
				WHEN Fiscal_Month LIKE '%April%' THEN 2
				WHEN Fiscal_Month LIKE '%May%' THEN 1
				WHEN Fiscal_Month LIKE '%June%' THEN 0
				END AS Extrap_Month_Left_ForFY
			FROM 

				(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month,
				SUM(CAST(IIF(Opportunity_Usage = 'NULL', 0, Opportunity_Usage) AS FLOAT)) AS Opportunity_Usage

				FROM

				(SELECT Store_No AS Account_No, Opportunity_Est_Date, Product,
				CASE	
					WHEN Product LIKE '%Products%' OR Product LIKE '%Product%' THEN 'Products'
					WHEN Product LIKE '%Service%' THEN 'Services'
					WHEN Product LIKE '%Support%' THEN 'Support'
					ELSE 'Need Mapping'
					END AS Product_Category,
					Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Usage, Opportunity_Stage  
				FROM Opportunities_Wk25
				WHERE Product IS NOT NULL AND Product <> 'NULL' AND Project_Status <> 'Inactive'
				)a

				LEFT JOIN

				(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b

				ON a.Opportunity_Est_Date = b.Date_Value

				GROUP BY a.Account_No, a.Product_Category, b.Fiscal_Month)a
		)a
		)b
	ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.Fiscal_Month = b.Fiscal_Month
	)a


FULL JOIN

	(
	--This is BAseline Target Opportunity Run rate Table

		SELECT  ISNULL(a.Account_No, b.Account_No) AS Account_No,
		ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
		ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS FIscal_Month,
		ISNULL(Baseline, 0) AS Baseline,
		ISNULL([Target], 0) AS [Target],
		ISNULL(Opportunity_INTO_Runrate, 0) AS Opportunity_INTO_Runrate

	FROM

		(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
		ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
		ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS FIscal_Month,
		ISNULL(Baseline, 0) AS Baseline,
		ISNULL([Target], 0) AS [Target]

		FROM
		----This is baseline view
			(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, a.Baseline

			FROM

				(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Partner_Fee + Revenue AS Baseline
					FROM
						(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
						SUM(Revenue) AS Revenue,
						SUM(Partner_Fee) AS Partner_Fee,
						SUM(Registration_Fee) AS Registration_Fee
						FROM
						(SELECT StoreNo AS Account_No, 
								[Month] AS Fiscal_Month, 
								Revenue_Type, Revenue_Motion, Product_Category, 
								Motion AS Account_Motion,
						CASE	
							WHEN Product_Category LIKE '%Product%' THEN 'Products'
							WHEN Product_Category LIKE '%Service%' THEN 'Services'
							WHEN Product_Category LIKE '%Support%' THEN 'Support'
							ELSE 'Need Mapping'
							END AS Product_Category_2,
						IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
						IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
						IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
						FROM Revenue_File_Wk25) a

						GROUP BY Account_No, Fiscal_Month, Product_Category_2
						)a

					LEFT JOIN

				(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
				ON a.Fiscal_Month = b.Date_Value
				WHERE a. Fiscal_Month = (SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
				)a

			CROSS JOIN


				(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
				(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
				(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
				)b
			)a

		FULL JOIN
		------This is Target View-----joining both

			(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, a.[Target]

			FROM

			(SELECT Store_Number AS Account_no, Service_Comp_Group AS Product_Category, Fiscal_Month, [Target]
			FROM Business_Targets1)a

			LEFT JOIN

			(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
			ON a.Fiscal_Month = b.Date_Value
			)b
		ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.Fiscal_Month = b.Fiscal_Month
		)a


	FULL JOIN

		(
		-----THIS IS Opportunity IN RR TABLE--

		SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, 
		IIF (Opportunity_Usage <0, 0, Opportunity_Usage) AS Opportunity_INTO_Runrate

		FROM

			(SELECT a.*, b.Fiscal_Month AS Future_Fiscal_Months, b.Month_ID+1 AS Est_Month_ID

			FROM

				(
				----This is Opportunity Extrapulation data-----------

				 SELECT a.*,
					IIF(Opportunity_Usage <0, 0, Extrap_Month_Left_ForFY* Opportunity_Usage) AS Opportunities_extrapulation
					FROM
						(SELECT a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID,
						SUM(a.Opportunity_Usage) AS Opportunity_Usage,
						CASE
							WHEN Fiscal_Month LIKE '%July%' THEN 11
							WHEN Fiscal_Month LIKE '%August%' THEN 10
							WHEN Fiscal_Month LIKE '%September%' THEN 9
							WHEN Fiscal_Month LIKE '%October%' THEN 8
							WHEN Fiscal_Month LIKE '%November%' THEN 7
							WHEN Fiscal_Month LIKE '%December%' THEN 6
							WHEN Fiscal_Month LIKE '%January%' THEN 5
							WHEN Fiscal_Month LIKE '%February%' THEN 4
							WHEN Fiscal_Month LIKE '%March%' THEN 3
							WHEN Fiscal_Month LIKE '%April%' THEN 2
							WHEN Fiscal_Month LIKE '%May%' THEN 1
							WHEN Fiscal_Month LIKE '%June%' THEN 0
							END AS Extrap_Month_Left_ForFY
						FROM 

							(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID,
							SUM(CAST(IIF(Opportunity_Usage = 'NULL', 0, Opportunity_Usage) AS FLOAT)) AS Opportunity_Usage

							FROM

							(SELECT Store_No AS Account_No, Opportunity_Est_Date, Product,
							CASE	
								WHEN Product LIKE '%Products%' OR Product LIKE '%Product%' THEN 'Products'
								WHEN Product LIKE '%Service%' THEN 'Services'
								WHEN Product LIKE '%Support%' THEN 'Support'
								ELSE 'Need Mapping'
								END AS Product_Category,
								Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Usage, Opportunity_Stage  
							FROM Opportunities_Wk25
							WHERE Product IS NOT NULL AND Product <> 'NULL' AND Project_Status <> 'Inactive'
							)a

							LEFT JOIN

							(SELECT DISTINCT Date_Value, Fiscal_Month, Fiscal_Year, Month_ID FROM Calendar_Lookup)b

							ON a.Opportunity_Est_Date = b.Date_Value

							WHERE
							a.Opportunity_Est_Date > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND
							b.Fiscal_Year = (SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
							GROUP BY a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID)a
			
							GROUP BY a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID
					)a 
				)a

				CROSS JOIN


					(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
					(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
					(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
					)b

				WHERE a.Month_ID <= b.Month_ID
				)a


				LEFT JOIN

				(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup
				)b

				ON a.Est_Month_ID = b.Month_ID

		)b
		ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.FIscal_Month = b.Fiscal_Month
	)b

	ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.FIscal_Month = b.Fiscal_Month


-------------JOINING All the Lookups with the Final Table---------------




CREATE VIEW revenue_summary AS

SELECT Final.*,
Fiscal_Quarter, Fiscal_Year, Month_ID,
Account_Name, Industry, Vertical, Segment, Store_Manager_Alias, Potential_Account, Vertical_Manager_Alias,
General_Seller, Services_Seller, Support_Seller, Product_Seller

FROM

	(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
		ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS Fiscal_Month,
		ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
		ISNULL(a. Revenue, 0) AS Revenue,
		ISNULL(a. Partner_Fee, 0) AS Partner_Fee,
		ISNULL(a. Registration_Fee, 0) AS Registration_Fee,
		ISNULL(a.Opportunity_Usage, 0) AS Opportunity_Usage,
		ISNULL(a.Opportunities_extrapulation, 0) AS Opportunities_Extrapulation,
		ISNULL(b. Baseline, 0) AS Baseline,
		ISNULL(b.[Target], 0) AS [Target],
		ISNULL(b.Opportunity_INTO_Runrate, 0) AS Opportunity_INTO_Runrate

		FROM


		(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
		ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS Fiscal_Month,
		ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
		ISNULL(Revenue, 0) AS Revenue,
		ISNULL(Partner_Fee, 0) AS Partner_Fee,
		ISNULL(Registration_Fee, 0) AS Registration_Fee,
		ISNULL(Opportunity_Usage, 0) AS Opportunity_Usage,
		ISNULL(Opportunities_extrapulation, 0) AS Opportunities_Extrapulation

		FROM
			------Revenue Table---
			(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Revenue, Partner_Fee, Registration_Fee
			FROM
				(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
				SUM(Revenue) AS Revenue,
				SUM(Partner_Fee) AS Partner_Fee,
				SUM(Registration_Fee) AS Registration_Fee
				FROM
				(SELECT StoreNo AS Account_No, 
						[Month] AS Fiscal_Month, 
						Revenue_Type, Revenue_Motion, Product_Category, 
						Motion AS Account_Motion,
				CASE	
					WHEN Product_Category LIKE '%Product%' THEN 'Products'
					WHEN Product_Category LIKE '%Service%' THEN 'Services'
					WHEN Product_Category LIKE '%Support%' THEN 'Support'
					ELSE 'Need Mapping'
					END AS Product_Category_2,
				IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
				IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
				IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
				FROM Revenue_File_Wk25) a

				GROUP BY Account_No, Fiscal_Month, Product_Category_2
				)a

			LEFT JOIN

			(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
			ON a.Fiscal_Month = b.Date_Value
			)a



		-----Account No, Product Category, Fiscal_Month	We will FULL join on these columns-----
	
		FULL JOIN
	
		---------This is Opportunity Extrabulation--------	
	(SELECT a.*,
	IIF(Opportunity_Usage <0, 0, Extrap_Month_Left_ForFY* Opportunity_Usage) AS Opportunities_extrapulation
	FROM
		(SELECT a.*,
		CASE
			WHEN Fiscal_Month LIKE '%July%' THEN 11
			WHEN Fiscal_Month LIKE '%August%' THEN 10
			WHEN Fiscal_Month LIKE '%September%' THEN 9
			WHEN Fiscal_Month LIKE '%October%' THEN 8
			WHEN Fiscal_Month LIKE '%November%' THEN 7
			WHEN Fiscal_Month LIKE '%December%' THEN 6
			WHEN Fiscal_Month LIKE '%January%' THEN 5
			WHEN Fiscal_Month LIKE '%February%' THEN 4
			WHEN Fiscal_Month LIKE '%March%' THEN 3
			WHEN Fiscal_Month LIKE '%April%' THEN 2
			WHEN Fiscal_Month LIKE '%May%' THEN 1
			WHEN Fiscal_Month LIKE '%June%' THEN 0
			END AS Extrap_Month_Left_ForFY
		FROM 

			(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month,
			SUM(CAST(IIF(Opportunity_Usage = 'NULL', 0, Opportunity_Usage) AS FLOAT)) AS Opportunity_Usage

			FROM

			(SELECT Store_No AS Account_No, Opportunity_Est_Date, Product,
			CASE	
				WHEN Product LIKE '%Products%' OR Product LIKE '%Product%' THEN 'Products'
				WHEN Product LIKE '%Service%' THEN 'Services'
				WHEN Product LIKE '%Support%' THEN 'Support'
				ELSE 'Need Mapping'
				END AS Product_Category,
				Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Usage, Opportunity_Stage  
			FROM Opportunities_Wk25
			WHERE Product IS NOT NULL AND Product <> 'NULL' AND Project_Status <> 'Inactive'
			)a

			LEFT JOIN

			(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b

			ON a.Opportunity_Est_Date = b.Date_Value

			GROUP BY a.Account_No, a.Product_Category, b.Fiscal_Month)a
	)a
	)b
ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.Fiscal_Month = b.Fiscal_Month
)a


FULL JOIN

(
--This is BAseline Target Opportunity Run rate Table

	SELECT  ISNULL(a.Account_No, b.Account_No) AS Account_No,
	ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
	ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS FIscal_Month,
	ISNULL(Baseline, 0) AS Baseline,
	ISNULL([Target], 0) AS [Target],
	ISNULL(Opportunity_INTO_Runrate, 0) AS Opportunity_INTO_Runrate

FROM

	(SELECT ISNULL(a.Account_No, b.Account_No) AS Account_No,
	ISNULL(a.Product_Category, b.Product_Category) AS Product_Category,
	ISNULL(a.Fiscal_Month, b.Fiscal_Month) AS FIscal_Month,
	ISNULL(Baseline, 0) AS Baseline,
	ISNULL([Target], 0) AS [Target]

FROM
----This is baseline view
	(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, a.Baseline

	FROM

		(SELECT a.Account_No, b.Fiscal_Month, a.Product_Category, Partner_Fee + Revenue AS Baseline
			FROM
				(SELECT Account_No, Fiscal_Month, Product_Category_2 AS Product_Category,
				SUM(Revenue) AS Revenue,
				SUM(Partner_Fee) AS Partner_Fee,
				SUM(Registration_Fee) AS Registration_Fee
				FROM
				(SELECT StoreNo AS Account_No, 
						[Month] AS Fiscal_Month, 
						Revenue_Type, Revenue_Motion, Product_Category, 
						Motion AS Account_Motion,
				CASE	
					WHEN Product_Category LIKE '%Product%' THEN 'Products'
					WHEN Product_Category LIKE '%Service%' THEN 'Services'
					WHEN Product_Category LIKE '%Support%' THEN 'Support'
					ELSE 'Need Mapping'
					END AS Product_Category_2,
				IIF(Revenue_Type = 'Actuals', Revenue, 0) AS Revenue,
				IIF(Revenue_Type = 'Partner Fee', Revenue, 0) AS Partner_Fee,
				IIF(Revenue_Type = 'Registration Fee', Revenue, 0) AS Registration_Fee
				FROM Revenue_File_Wk25) a

				GROUP BY Account_No, Fiscal_Month, Product_Category_2
				)a

			LEFT JOIN

		(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
		ON a.Fiscal_Month = b.Date_Value
		WHERE a. Fiscal_Month = (SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
		)a

	CROSS JOIN


		(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
		(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
		(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
		)b
	)a

	FULL JOIN
	------This is Target View-----joining both

		(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, a.[Target]

		FROM

		(SELECT Store_Number AS Account_no, Service_Comp_Group AS Product_Category, Fiscal_Month, [Target]
		FROM Business_Targets1)a

		LEFT JOIN

		(SELECT DISTINCT Date_Value, Fiscal_Month FROM Calendar_Lookup)b
		ON a.Fiscal_Month = b.Date_Value
		)b
	ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.Fiscal_Month = b.Fiscal_Month
	)a


FULL JOIN

	(
	-----THIS IS Opportunity IN RR TABLE--

	SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, 
	IIF (Opportunity_Usage <0, 0, Opportunity_Usage) AS Opportunity_INTO_Runrate

	FROM

		(SELECT a.*, b.Fiscal_Month AS Future_Fiscal_Months, b.Month_ID+1 AS Est_Month_ID

		FROM

	(
	----This is Opportunity Extrapulation data-----------

		SELECT a.*,
		IIF(Opportunity_Usage <0, 0, Extrap_Month_Left_ForFY* Opportunity_Usage) AS Opportunities_extrapulation
		FROM
		(SELECT a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID,
		SUM(a.Opportunity_Usage) AS Opportunity_Usage,
		CASE
			WHEN Fiscal_Month LIKE '%July%' THEN 11
			WHEN Fiscal_Month LIKE '%August%' THEN 10
			WHEN Fiscal_Month LIKE '%September%' THEN 9
			WHEN Fiscal_Month LIKE '%October%' THEN 8
			WHEN Fiscal_Month LIKE '%November%' THEN 7
			WHEN Fiscal_Month LIKE '%December%' THEN 6
			WHEN Fiscal_Month LIKE '%January%' THEN 5
			WHEN Fiscal_Month LIKE '%February%' THEN 4
			WHEN Fiscal_Month LIKE '%March%' THEN 3
			WHEN Fiscal_Month LIKE '%April%' THEN 2
			WHEN Fiscal_Month LIKE '%May%' THEN 1
			WHEN Fiscal_Month LIKE '%June%' THEN 0
			END AS Extrap_Month_Left_ForFY
		FROM 

			(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID,
			SUM(CAST(IIF(Opportunity_Usage = 'NULL', 0, Opportunity_Usage) AS FLOAT)) AS Opportunity_Usage
								

			FROM

			(SELECT Store_No AS Account_No, Opportunity_Est_Date, Product,
			CASE	
				WHEN Product LIKE '%Products%' OR Product LIKE '%Product%' THEN 'Products'
				WHEN Product LIKE '%Service%' THEN 'Services'
				WHEN Product LIKE '%Support%' THEN 'Support'
				ELSE 'Need Mapping'
				END AS Product_Category,
				Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Usage, Opportunity_Stage  
			FROM Opportunities_Wk25
			WHERE Product IS NOT NULL AND Product <> 'NULL' AND Project_Status <> 'Inactive'
			)a

				LEFT JOIN

				(SELECT DISTINCT Date_Value, Fiscal_Month, Fiscal_Year, Month_ID FROM Calendar_Lookup)b

				ON a.Opportunity_Est_Date = b.Date_Value

				WHERE
				a.Opportunity_Est_Date > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND
				b.Fiscal_Year = (SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
				GROUP BY a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID)a
			
				GROUP BY a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID
		)a 
	)a

	CROSS JOIN


		(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup WHERE Date_Value > (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0) AND Fiscal_Year = 
		(SELECT DISTINCT Fiscal_Year FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0)) AND Fiscal_Month <>
		(SELECT DISTINCT Fiscal_Month FROM Calendar_Lookup WHERE Date_Value = (SELECT MAX([MONTH]) FROM Revenue_File_Wk25 WHERE Revenue <> 0))
		)b

	WHERE a.Month_ID <= b.Month_ID
	)a


			LEFT JOIN

			(SELECT DISTINCT Fiscal_Month, Month_ID FROM Calendar_Lookup
			)b

			ON a.Est_Month_ID = b.Month_ID

	)b
	ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.FIscal_Month = b.Fiscal_Month
)b

ON a.Account_No = b.Account_No AND a.Product_Category = b.Product_Category AND a.FIscal_Month = b.Fiscal_Month
)Final

LEFT JOIN 

------THIS IS CALENDAR LOOK UP---

(SELECT DISTINCT Fiscal_Month, Fiscal_Quarter, Fiscal_Year, Month_ID FROM Calendar_Lookup
)b

ON Final.Fiscal_Month = b.Fiscal_Month


LEFT JOIN
---This is  Store Look Up-----

(SELECT AccountNo, Store AS Account_Name, Industry, Vertical, Segment, Store_Manager_Alias, Potential_Account, Vertical_Manager_Alias FROM Store_Lookup
)c

ON Final.Account_No = c.AccountNo


LEFT JOIN

---This is Seller Look Up-----
(Select Store_ID, General_Seller, Services_Seller, [Support_Seller], Product_Seller FROM Sellers_Lookup
)d

ON Final.Account_No = d.Store_ID


SELECT * FROM revenue_summary -------------This is the view created using CREATE VIEW---All the table are joined here-------

---------Now creating Opportunity View------

-------------------------------------------------------
-------------------------------------------------------------
---------------------------------------------------------------

CREATE VIEW Opportunity_Summary AS

SELECT a.*,
CASE 
	WHEN Opportunity_Usage <0 THEN 'Below 0$'
	WHEN Opportunity_Usage BETWEEN 0 AND 10000 THEN '$0- $10,000'
	WHEN Opportunity_Usage BETWEEN 10000 AND 50000 THEN '$10K- $50K'
	WHEN Opportunity_Usage BETWEEN 50000 AND 100000 THEN '$50K- $100K'
	WHEN Opportunity_Usage BETWEEN 100000 AND 200000 THEN '$100K- $200K'
	ELSE '$200K +'
	END Opportunity_Usage_Range,
	

CASE 
	WHEN Opportunities_extrapulation <0 THEN 'Below 0$'
	WHEN Opportunities_extrapulation BETWEEN 0 AND 10000 THEN '$0- $10,000'
	WHEN Opportunities_extrapulation BETWEEN 10000 AND 50000 THEN '$10K- $50K'
	WHEN Opportunities_extrapulation BETWEEN 50000 AND 100000 THEN '$50K- $100K'
	WHEN Opportunity_Usage BETWEEN 100000 AND 20000 THEN '$100K- $200K'
	ELSE '$200K +'
	END Opportunities_extrapulation_Range,

Fiscal_Quarter, Fiscal_Year,
Store_ID, General_Seller, Services_Seller, [Support_Seller], Product_Seller,
Account_Name, Industry, Vertical, Segment, Store_Manager_Alias, Potential_Account, Vertical_Manager_Alias

FROM

(
 ----This is Opportunity Extrapulation data-----------

	SELECT a.*,
	IIF(Opportunity_Usage <0, 0, Extrap_Month_Left_ForFY* Opportunity_Usage) AS Opportunities_extrapulation
	FROM
		(SELECT a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID, Product, Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Stage,

		SUM(a.Opportunity_Usage) AS Opportunity_Usage,
		CASE
			WHEN Fiscal_Month LIKE '%July%' THEN 12
			WHEN Fiscal_Month LIKE '%August%' THEN 11
			WHEN Fiscal_Month LIKE '%September%' THEN 10
			WHEN Fiscal_Month LIKE '%October%' THEN 9
			WHEN Fiscal_Month LIKE '%November%' THEN 8
			WHEN Fiscal_Month LIKE '%December%' THEN 7
			WHEN Fiscal_Month LIKE '%January%' THEN 6
			WHEN Fiscal_Month LIKE '%February%' THEN 5
			WHEN Fiscal_Month LIKE '%March%' THEN 4
			WHEN Fiscal_Month LIKE '%April%' THEN 3
			WHEN Fiscal_Month LIKE '%May%' THEN 2
			WHEN Fiscal_Month LIKE '%June%' THEN 1
			END AS Extrap_Month_Left_ForFY
		FROM 

			(SELECT a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID, Product, Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Stage,
			SUM(CAST(IIF(Opportunity_Usage = 'NULL', 0, Opportunity_Usage) AS FLOAT)) AS Opportunity_Usage

			FROM

			(SELECT Store_No AS Account_No, Opportunity_Est_Date, Product,
			CASE	
				WHEN Product LIKE '%Products%' OR Product LIKE '%Product%' THEN 'Products'
				WHEN Product LIKE '%Service%' THEN 'Services'
				WHEN Product LIKE '%Support%' THEN 'Support'
				ELSE 'Need Mapping'
				END AS Product_Category,
				Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Usage, Opportunity_Stage  
			FROM Opportunities_Wk25
			WHERE Product IS NOT NULL AND Product <> 'NULL'
			)a

			LEFT JOIN

			(SELECT DISTINCT Date_Value, Fiscal_Month, Fiscal_Year, Month_ID FROM Calendar_Lookup)b

			ON a.Opportunity_Est_Date = b.Date_Value

			GROUP BY a.Account_No, a.Product_Category, b.Fiscal_Month, b.Month_ID, Product, Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Stage 
				)a

				GROUP BY a.Account_No, a.Product_Category, a.Fiscal_Month, a.Month_ID, Product, Opportunity_ID, Opportunity_Name, Project_Status, Opportunity_Status, Opportunity_Stage
		)a 
		)a

LEFT JOIN
				
(SELECT DISTINCT Fiscal_Month, Fiscal_Quarter, Fiscal_Year, Month_ID FROM Calendar_Lookup
)b

ON a.Fiscal_Month = b.Fiscal_Month


LEFT JOIN
---This is  Store Look Up-----

(SELECT AccountNo, Store AS Account_Name, Industry, Vertical, Segment, Store_Manager_Alias, Potential_Account, Vertical_Manager_Alias FROM Store_Lookup
)c

ON a.Account_No = c.AccountNo


LEFT JOIN

---This is Seller Look Up-----
(Select Store_ID, General_Seller, Services_Seller, [Support_Seller], Product_Seller FROM Sellers_Lookup
)d

ON a.Account_No = d.Store_ID


SELECT * FROM Opportunity_Summary
			
			

SELECT * FROM revenue_summary