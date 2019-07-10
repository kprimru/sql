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

CREATE PROCEDURE [dbo].[REPORT_POSITION_SELECT] 	
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT RP_ID, RP_NAME, RP_PSEDO 
	FROM dbo.ReportPositionTable 
	WHERE RP_ACTIVE = ISNULL(@active, RP_ACTIVE)
	ORDER BY RP_NAME
	
	SET NOCOUNT OFF
END





