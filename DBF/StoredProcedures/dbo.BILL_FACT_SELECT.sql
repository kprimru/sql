USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
�����:			������� �������/������ ��������
���� ��������:  25.05.2009	
��������:		
*/
CREATE PROCEDURE [dbo].[BILL_FACT_SELECT]
	@date VARCHAR(100),
	@courid VARCHAR(MAX) = NULL
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

	SELECT dbo.BillFactMasterTable.*
	FROM 
		dbo.BillFactMasterTable INNER JOIN 
		#cour ON COUR_ID = 
			(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
	WHERE BFM_DATE = @d 
	ORDER BY COUR_ID	
		
	SELECT dbo.BillFactDetailTable.* 
	FROM 
		dbo.BillFactDetailTable INNER JOIN
		dbo.BillFactMasterTable ON BFD_ID_BFM = BFM_ID INNER JOIN
		#cour ON COUR_ID = 
			(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CL_ID ORDER BY TO_ID_COUR)
	WHERE BFM_DATE = @d
	ORDER BY CO_NUM, SYS_ORDER, DIS_NUM, PR_DATE

	IF OBJECT_ID('tempdb..#cour') IS NOT NULL
		DROP TABLE #cour
END