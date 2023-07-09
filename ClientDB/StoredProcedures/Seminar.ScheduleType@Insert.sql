USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[ScheduleType@Insert]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[ScheduleType@Insert]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[ScheduleType@Insert]
	@Id		SmallInt = NULL OUTPUT,
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

		INSERT INTO [Seminar].[Schedules->Types]([Code], [Name], [PlaceTemplate])
		VALUES (@Code, @Name, @Place);

		SELECT @Id = Scope_Identity();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[ScheduleType@Insert] TO rl_seminar_schedule_type_r;
GO
