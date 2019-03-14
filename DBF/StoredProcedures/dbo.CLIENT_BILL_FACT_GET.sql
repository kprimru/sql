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

CREATE PROCEDURE [dbo].[CLIENT_BILL_FACT_GET]
	@clientid INT,
	@date VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @d DATETIME
	SET @d = CONVERT(DATETIME, @date, 121)

	SELECT * 
	FROM dbo.BillFactMasterTable 
	WHERE BFM_DATE = @d AND CL_ID = @clientid	

	SELECT BillFactDetailTable.* 
	FROM 
		dbo.BillFactDetailTable INNER JOIN
		dbo.BillFactMasterTable ON BFD_ID_BFM = BFM_ID
	WHERE BFM_DATE = @d
END



