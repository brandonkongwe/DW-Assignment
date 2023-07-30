/* ETL Script for DIM_DATE */

USE CarSales_DW;

DECLARE @CurrentDate DATE = '1980-01-01'; --start date
DECLARE @Interval INT  = 20; --years for forecasting into the future
DECLARE @EndDate  DATE =  CAST(CAST((YEAR(GetDate()) + @Interval) AS VARCHAR(4)) + '-12-31' AS DATE); --current date + @Interval years for forecasting

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO DIM_DATE (
		DATEKEY,
		[DATE],
		[DAY],
		[WEEKDAY],
		WEEKDAYNAME,
		SHORTWEEKDAYNAME,
		[DAYOFYEAR],
		WEEKOFMONTH,
		WEEKOFYEAR,
		[MONTH],
		[MONTHNAME],
		SHORTMONTHNAME,
		SEASON,
		[QUARTER],
		QUARTERNAME,
		[YEAR],
		MMYYYY,
		MONTHYEAR,
		ISWEEKEND,
		ISHOLIDAY,
		HOLIDAYNAME,
		SPECIALDAYS,
		FINANCIALYEAR,
		FINANCIALQUARTER,
		FINANCIALMONTH,
		FIRSTDATEOFYEAR,
		LASTDATEOFYEAR,
		FIRSTDATEOFQUARTER,
		LASTDATEOFQUARTER,
		FIRSTDATEOFMONTH,
		LASTDATEOFMONTH,
		FIRSTDATEOFWEEK,
		LASTDATEOFWEEK
      )

SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
      [DATE] = @CurrentDate,
      [DAY] = DAY(@CurrentDate),
      [WEEKDAY] = DATEPART(dw, @CurrentDate),
      WEEKDAYNAME = DATENAME(dw, @CurrentDate),
      SHORTWEEKDAYNAME = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)),
      [DAYOFYEAR] = DATENAME(dy, @CurrentDate),
      [WEEKOFMONTH] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1,
      [WEEKOFYEAR] = DATEPART(wk, @CurrentDate),
      [MONTH] = MONTH(@CurrentDate),
      [MONTHNAME] = DATENAME(mm, @CurrentDate),
      [SHORTMONTHNAME] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
	  SEASON = CASE 
					WHEN MONTH(@CurrentDate) IN (12,1,2)  THEN 'Summer'
					WHEN MONTH(@CurrentDate) IN (3,4,5)   THEN 'Autumn'
					WHEN MONTH(@CurrentDate) IN (6,7,8)   THEN 'Winter'
					WHEN MONTH(@CurrentDate) IN (9,10,11) THEN 'Spring'
				END,
      [QUARTER] = DATEPART(q, @CurrentDate),
      [QUARTERNAME] = CASE 
         WHEN DATENAME(qq, @CurrentDate) = 1
            THEN 'First'
         WHEN DATENAME(qq, @CurrentDate) = 2
            THEN 'Second'
         WHEN DATENAME(qq, @CurrentDate) = 3
            THEN 'Third'
         WHEN DATENAME(qq, @CurrentDate) = 4
            THEN 'Fourth'
         END,
      [YEAR] = YEAR(@CurrentDate),
      [MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)),
      [MONTHYEAR] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [ISWEEKEND] = CASE 
         WHEN DATENAME(dw, @CurrentDate) = 'Sunday'
            OR DATENAME(dw, @CurrentDate) = 'Saturday'
            THEN 1
         ELSE 0
         END,
      [ISHOLIDAY] = 0,
	  HOLIDAYNAME = '',
	  SPECIALDAYS = '',
	  FINANCIALYEAR    = NULL,
	  FINANCIALQUARTER = NULL,
	  FINANCIALMONTH   = NULL,
      [FIRSTDATEOFYEAR] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
      [LASTDATEOFYEAR] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
      [FIRSTDATEOFQUARTER] = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0),
      [LASTDATEOFQUARTER] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)),
      [FIRSTDATEOFMONTH] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
      [LASTDATEOFMONTH] = EOMONTH(@CurrentDate),
      [FIRSTDATEOFWEEK] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
      [LASTDATEOFWEEK] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)
   ----INCREMENT TO NEXT DATE -- FOR PROCESSING----
   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

--Update Holiday information
UPDATE Dim_Date
SET [IsHoliday] = 1,
   [HOLIDAYNAME] = 'Christmas'
WHERE [Month] = 12
   AND [DAY] = 25

UPDATE Dim_Date
SET SPECIALDAYS = 'Valentines Day'
WHERE [Month] = 2
   AND [DAY] = 14

--Update current date information
/*
UPDATE Dim_Date
SET CurrentYear   = DATEDIFF(yy, GETDATE(), DATE),
    CurrentQuater = DATEDIFF(q, GETDATE() , DATE),
    CurrentMonth  = DATEDIFF(m, GETDATE() , DATE),
    CurrentWeek   = DATEDIFF(ww, GETDATE(), DATE),
    CurrentDay    = DATEDIFF(dd, GETDATE(), DATE)
*/


/* End of ETL Script for DIM_DATE */
