USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[PERIOD_GET] 
	@periodid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PR_ID, PR_NAME, PR_DATE, PR_END_DATE, PR_BREPORT, PR_EREPORT, PR_ACTIVE
	FROM dbo.PeriodTable 
	WHERE PR_ID = @periodid   

	SET NOCOUNT OFF
END








