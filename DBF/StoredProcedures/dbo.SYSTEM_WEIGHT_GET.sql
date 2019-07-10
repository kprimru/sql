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

CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_GET] 
	@swid INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT SW_ID, SYS_SHORT_NAME, SYS_ID, PR_DATE, PR_ID, SW_WEIGHT, SW_PROBLEM, SW_ACTIVE
	FROM 
		dbo.SystemWeightTable a INNER JOIN
		dbo.SystemTable b ON a.SW_ID_SYSTEM = b.SYS_ID INNER JOIN
		dbo.PeriodTable c ON c.PR_ID = a.SW_ID_PERIOD
	WHERE SW_ID = @swid

	SET NOCOUNT OFF
END








