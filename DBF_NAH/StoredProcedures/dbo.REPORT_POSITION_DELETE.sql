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

ALTER PROCEDURE [dbo].[REPORT_POSITION_DELETE]
	@positionreportid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.ReportPositionTable
	WHERE RP_ID = @positionreportid

	SET NOCOUNT OFF
END


GO
GRANT EXECUTE ON [dbo].[REPORT_POSITION_DELETE] TO rl_report_position_d;
GO