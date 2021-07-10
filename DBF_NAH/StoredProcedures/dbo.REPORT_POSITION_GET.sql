USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[REPORT_POSITION_GET]
	@positionreportid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT RP_ID, RP_NAME, RP_PSEDO, RP_ACTIVE
	FROM dbo.ReportPositionTable
	WHERE RP_ID = @positionreportid 

	SET NOCOUNT OFF
END






GO
GRANT EXECUTE ON [dbo].[REPORT_POSITION_GET] TO rl_report_position_r;
GO