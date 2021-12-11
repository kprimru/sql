USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CALENDAR_WORK_ARCH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CALENDAR_WORK_ARCH]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CALENDAR_WORK_ARCH]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO dbo.CalendarDate(ID_MASTER, DATE, ID_TYPE, NAME, NOTE, STATUS, UPD_DATE, UPD_USER)
			SELECT ID, DATE, ID_TYPE, NAME, NOTE, 2, UPD_DATE, UPD_USER
			FROM dbo.CalendarDate
			WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CALENDAR_WORK_ARCH] TO rl_work_calendar_u;
GO
