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

CREATE PROCEDURE [dbo].[DISTR_SERVICE_GET] 
	@dsid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT DSS_NAME, DSS_ID, DSS_SUBHOST, DS_ID, DS_NAME, DSS_REPORT, DSS_ACTIVE
	FROM 
		dbo.DistrServiceStatusTable LEFT OUTER JOIN
		dbo.DistrStatusTable ON DS_ID = DSS_ID_STATUS
	WHERE DSS_ID = @dsid 
	ORDER BY DSS_NAME

	SET NOCOUNT OFF
END








