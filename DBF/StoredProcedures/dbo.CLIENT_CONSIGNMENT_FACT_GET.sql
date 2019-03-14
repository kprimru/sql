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

CREATE PROCEDURE [dbo].[CLIENT_CONSIGNMENT_FACT_GET]
	@clientid INT,
	@date VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @d DATETIME
	SET @d = CONVERT(DATETIME, @date, 121)

	SELECT * 
	FROM dbo.ConsignmentFactMasterTable 
	WHERE CFM_DATE = @d AND CL_ID = @clientid	

	SELECT ConsignmentFactDetailTable.* 
	FROM 
		dbo.ConsignmentFactDetailTable INNER JOIN
		dbo.ConsignmentFactMasterTable ON CFD_ID_CFM = CFM_ID
	WHERE CFM_DATE = @d
END



