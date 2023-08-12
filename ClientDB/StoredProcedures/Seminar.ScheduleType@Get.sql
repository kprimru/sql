USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[ScheduleType@Get]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[ScheduleType@Get]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[ScheduleType@Get]
	@Id		SmallInt
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

		SELECT S.[Id], S.[Code], S.[Name], S.[PlaceTemplate]
		FROM [Seminar].[Schedules->Types] AS S
		WHERE [Id] = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[ScheduleType@Get] TO rl_seminar_schedule_type_r;
GO
