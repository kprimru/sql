USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[BILL_ALL_CREATE]
	@periodid SMALLINT,
	@billdate SMALLDATETIME,
	@soid SMALLINT = 1,
	@fin_date bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TXT VARCHAR(MAX)
	
	SELECT @TXT = 'Период: ' + CONVERT(VARCHAR(MAX), PR_DATE, 104)
	FROM dbo.PeriodTable
	WHERE PR_ID = @periodid

	EXEC dbo.FINANCING_PROTOCOL_ADD 'BILL_ALL', 'Начало прямого формирования счетов', @TXT, NULL, NULL

	DECLARE CL CURSOR LOCAL FOR
		SELECT CL_ID
		FROM 
			dbo.ClientTable 
		WHERE 
			EXISTS
				(
					SELECT * 
					FROM			
						dbo.ClientDistrTable INNER JOIN
						dbo.DistrFinancingTable ON DF_ID_DISTR = CD_ID_DISTR INNER JOIN
						dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
					WHERE CD_ID_CLIENT = CL_ID AND DSS_REPORT = 1
				)
		ORDER BY CL_PSEDO

	DECLARE @clid INT

	OPEN CL

	FETCH NEXT FROM CL INTO @clid

	WHILE @@FETCH_STATUS = 0 
		BEGIN
			EXEC dbo.BILL_CREATE @clid,	@periodid, @billdate, @soid, @fin_date

			FETCH NEXT FROM CL INTO @clid
		END

	CLOSE CL
	DEALLOCATE CL
	
	EXEC dbo.FINANCING_PROTOCOL_ADD 'BILL_ALL', 'Начало обратного формирования счетов', @TXT, NULL, NULL
	
	DECLARE CL_REVERSE CURSOR LOCAL FOR
		SELECT CL_ID
		FROM 
			dbo.ClientTable 
		WHERE 
			EXISTS
				(
					SELECT * 
					FROM			
						dbo.ClientDistrTable INNER JOIN
						dbo.DistrFinancingTable ON DF_ID_DISTR = CD_ID_DISTR INNER JOIN
						dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
					WHERE CD_ID_CLIENT = CL_ID AND DSS_REPORT = 1
				)
		ORDER BY CL_PSEDO DESC

	OPEN CL_REVERSE

	FETCH NEXT FROM CL_REVERSE INTO @clid

	WHILE @@FETCH_STATUS = 0 
		BEGIN
			EXEC dbo.BILL_CREATE @clid,	@periodid, @billdate, @soid, @fin_date

			FETCH NEXT FROM CL_REVERSE INTO @clid
		END

	CLOSE CL_REVERSE
	DEALLOCATE CL_REVERSE
	
	EXEC dbo.FINANCING_PROTOCOL_ADD 'BILL_ALL', 'Окончание формирования счетов', @TXT, NULL, NULL
END

