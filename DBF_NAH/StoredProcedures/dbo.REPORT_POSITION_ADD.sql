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

ALTER PROCEDURE [dbo].[REPORT_POSITION_ADD]
	@positionreportname VARCHAR(100),
	@positionreportpsedo VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ReportPositionTable(RP_NAME, RP_PSEDO, RP_ACTIVE)
	VALUES (@positionreportname, @positionreportpsedo, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END








GO
GRANT EXECUTE ON [dbo].[REPORT_POSITION_ADD] TO rl_report_position_w;
GO