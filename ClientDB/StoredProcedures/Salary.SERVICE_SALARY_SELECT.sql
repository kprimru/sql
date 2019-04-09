USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[SERVICE_SALARY_SELECT]
	@MONTH		UNIQUEIDENTIFIER,
	@SERVICE	INT,
	@DISTR		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ID, c.ServiceName, d.ServicePositionName, MANAGER_RATE, INSURANCE, b.NAME,
		(
			SELECT COUNT(*)
			FROM Salary.ServiceStudy z
			WHERE z.ID_SALARY = a.ID
		) AS STUDY_COUNT,
		(
			SELECT SUM(ISNULL(PRICE_NEW, 0) - ISNULL(PRICE_OLD, 0))
			FROM Salary.ServiceDistr z
			WHERE z.ID_SALARY = a.ID
		) AS PRICE_DELTA,
		(
			SELECT SUM(ISNULL(WEIGHT_NEW, 0) - ISNULL(WEIGHT_OLD, 0))
			FROM Salary.ServiceDistr z
			WHERE z.ID_SALARY = a.ID
		) AS WEIGHT_DELTA,
		(
			SELECT COUNT(*)
			FROM Salary.ServiceClient z
			WHERE ID_SALARY = a.ID
		) AS CL_COUNT,
		(
			SELECT COUNT(*)
			FROM 
				Salary.ServiceClient z
				INNER JOIN Salary.Service p ON z.ID_SALARY = p.ID
			WHERE z.ID_SALARY = a.ID
				AND NOT EXISTS
					(
						SELECT *
						FROM 
							Salary.ServiceClient y
							INNER JOIN Salary.Service t ON y.ID_SALARY = t.ID
						WHERE t.ID_SERVICE = p.ID_SERVICE
							AND y.ID_CLIENT = z.ID_CLIENT
							AND y.ID_SALARY = 
								(
									SELECT ID
									FROM Salary.Service x
									WHERE x.ID_SERVICE = a.ID_SERVICE
										AND x.ID_MONTH = 
											(
												SELECT ID
												FROM Common.Period w
												WHERE w.START = DATEADD(MONTH, -1, (SELECT START FROM Common.Period p WHERE p.ID = a.ID_MONTH))
													 AND TYPE = 2
											)
								)
					)
		) AS CL_PLUS,
		(
			SELECT COUNT(*)
			FROM 
				Salary.ServiceClient z
				INNER JOIN Salary.Service p ON z.ID_SALARY = p.ID
			WHERE z.ID_SALARY = 
				(
					SELECT ID
					FROM Salary.Service x
					WHERE x.ID_SERVICE = a.ID_SERVICE
						AND x.ID_MONTH = 
							(
								SELECT ID
								FROM Common.Period w
								WHERE w.START = DATEADD(MONTH, -1, (SELECT START FROM Common.Period p WHERE p.ID = a.ID_MONTH))
									 AND TYPE = 2
							)
				)
				AND NOT EXISTS
					(
						SELECT *
						FROM 
							Salary.ServiceClient y
							INNER JOIN Salary.Service t ON y.ID_SALARY = t.ID
						WHERE t.ID_SERVICE = p.ID_SERVICE
							AND y.ID_CLIENT = z.ID_CLIENT
							AND y.ID_SALARY = a.ID
								
					)
		) AS CL_MINUS
	FROM 
		Salary.Service a
		INNER JOIN Common.Period b ON a.ID_MONTH  = b.ID
		INNER JOIN dbo.ServiceTable c ON a.ID_SERVICE = c.ServiceID
		INNER JOIN dbo.ServicePositionTable d ON a.ID_POSITION = d.ServicePositionID
	WHERE (a.ID_MONTH = @MONTH OR @MONTH IS NULL)
		AND (a.ID_SERVICE = @SERVICE OR @SERVICE IS NULL)
		AND
			(
				@DISTR IS NULL 
				OR
				EXISTS
					(
						SELECT *
						FROM Salary.ServiceDistr z
						WHERE z.ID_SALARY = a.ID
							AND z.DISTR = @DISTR
					)
			)
	ORDER BY b.START DESC, c.ServiceName
END
