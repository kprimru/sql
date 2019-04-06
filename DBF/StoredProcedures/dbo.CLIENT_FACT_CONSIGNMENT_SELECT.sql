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

CREATE PROCEDURE [dbo].[CLIENT_FACT_CONSIGNMENT_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CFM_DATE, 
		(
			SELECT SUM(CSD_TOTAL_PRICE)
			FROM dbo.ConsignmentFactDetailTable
			WHERE CFD_ID_CFM = CFM_ID
		) AS CSD_TOTAL_PRICE, 
		CFM_NUM
	FROM dbo.ConsignmentFactMasterTable
	WHERE CL_ID = @clientid
	ORDER BY CFM_DATE DESC

	SET NOCOUNT OFF
END





