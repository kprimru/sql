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

CREATE PROCEDURE [dbo].[DISTR_SERVICE_CHECK_NAME] 
	@dsname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT DSS_ID
	FROM dbo.DistrServiceStatusTable
	WHERE DSS_NAME = @dsname 

	SET NOCOUNT OFF
END






