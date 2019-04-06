USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[DISTR_SERVICE_ADD] 
	@dsname VARCHAR(100),
	@statusid SMALLINT,
	@subhost BIT,
	@dsreport BIT,
	@active BIT = 1,  
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.DistrServiceStatusTable
		(
			DSS_NAME, DSS_ID_STATUS, DSS_SUBHOST,DSS_REPORT, DSS_ACTIVE, DSS_OLD_CODE
		)
	VALUES (@dsname, @statusid, @subhost, @dsreport, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END








