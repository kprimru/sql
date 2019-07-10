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

CREATE PROCEDURE [dbo].[DISTR_SERVICE_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT DSS_NAME, DSS_REPORT, DSS_ID 
	FROM dbo.DistrServiceStatusTable 
	WHERE DSS_ACTIVE = ISNULL(@active, DSS_ACTIVE)
	ORDER BY DSS_NAME

	SET NOCOUNT OFF
END






