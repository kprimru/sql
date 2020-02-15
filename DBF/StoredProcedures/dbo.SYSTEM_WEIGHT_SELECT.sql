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

CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_SELECT]
	@active BIT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SW_ID, SYS_SHORT_NAME, SYS_ID, PR_DATE, PR_ID, SW_WEIGHT, SW_ACTIVE, SW_PROBLEM
	FROM 
		dbo.SystemWeightTable a INNER JOIN
		dbo.SystemTable b ON a.SW_ID_SYSTEM = b.SYS_ID INNER JOIN
		dbo.PeriodTable c ON c.PR_ID = a.SW_ID_PERIOD	
	WHERE SW_ACTIVE = ISNULL(@active, SW_ACTIVE)-- AND DATEPART(YEAR, PR_DATE) = '2011'
	ORDER BY PR_DATE DESC, SYS_ORDER
END
