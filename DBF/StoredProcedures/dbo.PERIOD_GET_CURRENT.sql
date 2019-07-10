USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[PERIOD_GET_CURRENT]  
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @date SMALLDATETIME

	SELECT @date = GETDATE()

	SELECT PR_ID , PR_NAME
	FROM dbo.PeriodTable	
	WHERE @date >= PR_DATE AND @date < DATEADD(day, 1, PR_END_DATE)

	SET NOCOUNT OFF
END













