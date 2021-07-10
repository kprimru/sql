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

ALTER PROCEDURE [dbo].[REPORT_POSITION_EDIT]
	@positionreportid INT,
	@positionreportname VARCHAR(100),
	@positionreportpsedo VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ReportPositionTable
	SET
		RP_NAME = @positionreportname,
		RP_PSEDO = @positionreportpsedo
	WHERE RP_ID = @positionreportid

	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON [dbo].[REPORT_POSITION_EDIT] TO rl_report_position_w;
GO