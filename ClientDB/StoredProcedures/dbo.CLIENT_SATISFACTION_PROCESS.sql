USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_SATISFACTION_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_SATISFACTION_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_SATISFACTION_PROCESS]
	@CALL	UNIQUEIDENTIFIER,
	@TYPE	UNIQUEIDENTIFIER,
	@NOTE	VARCHAR(MAX),
	@CTYPE	TINYINT,
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

		DECLARE @CS_ID UNIQUEIDENTIFIER

		SELECT @CS_ID = CS_ID
		FROM dbo.ClientSatisfaction
		WHERE CS_ID_CALL = @CALL

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		IF @CS_ID IS NULL
		BEGIN
			INSERT INTO dbo.ClientSatisfaction(CS_ID_CALL, CS_ID_TYPE, CS_NOTE, CS_TYPE)
				OUTPUT INSERTED.CS_ID INTO @TBL
				VALUES(@CALL, @TYPE, @NOTE, @CTYPE)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE dbo.ClientSatisfaction
			SET CS_ID_TYPE = @TYPE,
				CS_NOTE = @NOTE,
				CS_TYPE = @CTYPE
			WHERE CS_ID_CALL = @CALL

			SELECT @ID = @CS_ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SATISFACTION_PROCESS] TO rl_client_call_i;
GRANT EXECUTE ON [dbo].[CLIENT_SATISFACTION_PROCESS] TO rl_client_call_u;
GO
