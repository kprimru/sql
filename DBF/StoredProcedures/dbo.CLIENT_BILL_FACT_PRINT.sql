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

CREATE PROCEDURE [dbo].[CLIENT_BILL_FACT_PRINT]
	@bfmid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *, (SELECT ORG_LOGO FROM dbo.OrganizationTable z WHERE a.ORG_ID = z.ORG_ID) AS ORG_LOGO, 0 AS TO_GROUP
	FROM dbo.BillFactMasterTable a
	WHERE BFM_ID = @bfmid

	SELECT *, NULL AS TO_NUM, NULL AS TO_NAME
	FROM dbo.BillFactDetailTable
	WHERE BFD_ID_BFM = @bfmid
	ORDER BY SYS_ORDER, DIS_ID, PR_DATE
END
