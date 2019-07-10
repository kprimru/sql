USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[INCOME_CONVEY_DEFAULT_GET]
	@incomeid INT
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT SYS_ID_SO
			FROM 
				dbo.IncomeTable INNER JOIN
				dbo.ClientTable ON CL_ID = IN_ID_CLIENT INNER JOIN
				dbo.ClientDistrView ON CD_ID_CLIENT = CL_ID 
			WHERE IN_ID = @incomeid AND DSS_REPORT = 1 AND SYS_ID_SO = 1
		)
	BEGIN
		SELECT SO_ID, SO_NAME, PR_ID, PR_DATE
		FROM dbo.SaleObjectTable, dbo.PeriodTable
		WHERE PR_DATE <= GETDATE() AND DATEADD(DAY, 1, PR_END_DATE) >= GETDATE() AND SO_ID = 1
	END
	ELSE
	BEGIN
		SELECT SO_ID, SO_NAME, PR_ID, PR_DATE
		FROM dbo.SaleObjectTable, dbo.PeriodTable
		WHERE PR_DATE <= GETDATE() AND DATEADD(DAY, 1, PR_END_DATE) >= GETDATE()
			AND SO_ID =	
				ISNULL((
					SELECT SYS_ID_SO
					FROM 
						dbo.IncomeTable INNER JOIN
						dbo.ClientTable ON CL_ID = IN_ID_CLIENT INNER JOIN
						dbo.ClientDistrView ON CD_ID_CLIENT = CL_ID 
					WHERE IN_ID = @incomeid AND DSS_REPORT = 1
				), 1)
	END	
END
