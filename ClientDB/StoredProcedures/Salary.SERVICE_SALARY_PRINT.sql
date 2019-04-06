USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[SERVICE_SALARY_PRINT]
	@PERIOD	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		ID, ServiceName, ServicePositionName, Name, CL_COUNT, INSURANCE, 
		MANAGER_RATE, STUDY_COUNT, PRICE_DELTA, WEIGHT_DELTA
	FROM
		(
			SELECT 
				ID, ServiceName, ServicePositionName, Name, CL_COUNT, INSURANCE,
				MANAGER_RATE, STUDY_COUNT, PRICE_DELTA, WEIGHT_DELTA
			FROM
				(
					SELECT 
						ID, ServiceName, ServicePositionName, NAME, BASE_PRICE, CL_COUNT, INSURANCE,
						MANAGER_RATE,
						STUDY_COUNT,
						PRICE_DELTA,						
						WEIGHT_DELTA
					FROM
						(
							SELECT 
								a.ID, c.ServiceName, d.ServicePositionName, MANAGER_RATE, INSURANCE, 3500 AS BASE_PRICE, b.NAME, 
								ISNULL((
									SELECT COUNT(*)
									FROM Salary.ServiceStudy z
									WHERE z.ID_SALARY = a.ID
								), 0) AS STUDY_COUNT,
								ISNULL((
									SELECT SUM(ISNULL(PRICE_NEW, 0) - ISNULL(PRICE_OLD, 0))
									FROM Salary.ServiceDistr z
									WHERE z.ID_SALARY = a.ID
								), 0) AS PRICE_DELTA,
								ISNULL((
									SELECT SUM(ISNULL(WEIGHT_NEW, 0) - ISNULL(WEIGHT_OLD, 0))
									FROM Salary.ServiceDistr z
									WHERE z.ID_SALARY = a.ID
								), 0) AS WEIGHT_DELTA,
								(
									SELECT COUNT(*)
									FROM Salary.ServiceClient z
									WHERE ID_SALARY = a.ID
								) AS CL_COUNT
							FROM 
								Salary.Service a
								INNER JOIN Common.Period b ON a.ID_MONTH  = b.ID
								INNER JOIN dbo.ServiceTable c ON a.ID_SERVICE = c.ServiceID
								INNER JOIN dbo.ServicePositionTable d ON a.ID_POSITION = d.ServicePositionID
							WHERE a.ID_MONTH = @PERIOD
						) AS a
				) AS a
		) AS a
	ORDER BY ServiceName
END
