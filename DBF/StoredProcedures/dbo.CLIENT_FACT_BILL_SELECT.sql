USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/
CREATE PROCEDURE [dbo].[CLIENT_FACT_BILL_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		BFM_ID,
		BFM_DATE, 
		(
			SELECT SUM(BD_TOTAL_UNPAY)
			FROM dbo.BillFactDetailTable
			WHERE BFD_ID_BFM = BFM_ID
		) AS BD_TOTAL_PRICE, 
		BFM_NUM, BFM_ID_PERIOD, BILL_DATE, ORG_PSEDO
	FROM 
		dbo.BillFactMasterTable a INNER JOIN
		dbo.OrganizationTable b ON a.ORG_ID = b.ORG_ID
	WHERE CL_ID = @clientid
	ORDER BY BFM_DATE DESC
END