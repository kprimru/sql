USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CALL_DIRECTION_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CALL_DIRECTION_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CALL_DIRECTION_INSERT]
	@NAME	VARCHAR(50),
	@DEF	BIT,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		IF @DEF = 1
			UPDATE dbo.CallDirection
			SET DEF = 0

		INSERT INTO dbo.CallDirection(NAME, DEF)
			OUTPUT INSERTED.ID INTO @TBL
			VALUES(@NAME, @DEF)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CALL_DIRECTION_INSERT] TO rl_call_direction_i;
GO
