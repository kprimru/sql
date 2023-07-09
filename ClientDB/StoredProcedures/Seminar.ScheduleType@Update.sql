USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[ScheduleType@Update]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[ScheduleType@Update]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[ScheduleType@Update]
	@Id		SmallInt,
	@Code	VarChar(100),
	@Name	VarChar(256),
	@Place	VarChar(Max)
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

		UPDATE [Seminar].[Schedules->Types] SET
			[Code]			= @Code,
			[Name]			= @Name,
			[PlaceTemplate] = @Place
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
GRANT EXECUTE ON [Seminar].[ScheduleType@Update] TO rl_seminar_schedule_type_u;
GO
