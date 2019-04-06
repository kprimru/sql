USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  25.05.2009	
Описание:		
*/
CREATE PROCEDURE [dbo].[CONSIGNMENT_FACT_SELECT]
	@date VARCHAR(100),
	@courid VARCHAR(1000) = NULL
AS
BEGIN
	IF OBJECT_ID('tempdb..#cour') IS NOT NULL
		DROP TABLE #cour

	CREATE TABLE #cour
		(
			COUR_ID SMALLINT
		)

	IF @courid IS NULL
		INSERT INTO #cour (COUR_ID)
			SELECT COUR_ID
			FROM dbo.CourierTable
	ELSE
		INSERT INTO #cour
			SELECT * FROM dbo.GET_TABLE_FROM_LIST(@courid, ',')	

	SET NOCOUNT ON;
	DECLARE @d DATETIME
	SET @d = CONVERT(DATETIME, @date, 121)

	SELECT ConsignmentFactMasterTable.*
	FROM 
		dbo.ConsignmentFactMasterTable INNER JOIN 
		#cour ON COUR_ID = 
			(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
	WHERE CFM_FACT_DATE = @d 
	ORDER BY COUR_ID	
		
	SELECT ConsignmentFactDetailTable.* 
	FROM 
		dbo.ConsignmentFactDetailTable INNER JOIN
		dbo.ConsignmentFactMasterTable ON CFD_ID_CFM = CFM_ID INNER JOIN
		#cour ON COUR_ID = 
			(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
	WHERE CFM_FACT_DATE = @d
	ORDER BY CSD_NUM

	IF OBJECT_ID('tempdb..#cour') IS NOT NULL
		DROP TABLE #cour
END