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

CREATE PROCEDURE [dbo].[CLIENT_GET_MONTH_NO_BILL]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PR_ID, PR_DATE, PR_NAME
	FROM dbo.PeriodTable a
	WHERE PR_DATE >
			(
				SELECT MAX(b.PR_DATE)
				FROM 
					dbo.PeriodTable b INNER JOIN
					dbo.BillTable c ON c.BL_ID_PERIOD = b.PR_ID
				WHERE BL_ID_CLIENT = @clientid					
			)	
END

