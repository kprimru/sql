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

CREATE PROCEDURE [dbo].[ACT_CALC_DEFAULT_GET]
	@clientid INT,
	@dt SMALLDATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SO_ID, SO_NAME, COUR_ID, COUR_NAME, PR_ID, PR_NAME
	FROM 
		dbo.SaleObjectTable,
		dbo.ClientCourView,
		dbo.PeriodTable
	WHERE SO_ID = 1 
		AND CL_ID = @clientid 
		AND ISNULL(@dt, GETDATE()) BETWEEN PR_DATE AND PR_END_DATE
END


