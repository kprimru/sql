USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_MESSAGE_DELAY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_MESSAGE_DELAY]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_MESSAGE_DELAY]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@CUR_DELAY			Int,
		@Setting_DELAY		Int,
		@Setting_DELAY_MAX	Int;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Setting_DELAY = Cast([System].[Setting@Get]('MESSAGE_DELAY') AS Int);
		SET @Setting_DELAY_MAX = Cast([System].[Setting@Get]('MESSAGE_DELAY_MAX') AS Int);

		SELECT @CUR_DELAY = [DELAY_MIN]
		FROM [dbo].[ClientMessage]
		WHERE [ID] = @ID;

		IF @CUR_DELAY <= @Setting_DELAY_MAX
		BEGIN
			INSERT INTO [dbo].[ClientMessage]([ID_MASTER], [ID_CLIENT], [TP], [SENDER], [DATE], [NOTE], [RECEIVE_USER], [RECEIVE_DATE], [RECEIVE_HOST], [HARD_READ], [DELAY_MIN], [REMIND_DATE], [HIDE], [STATUS], [UPD_DATE], [UPD_USER])
				SELECT [ID], [ID_CLIENT], [TP], [SENDER], [DATE], [NOTE], [RECEIVE_USER], [RECEIVE_DATE], [RECEIVE_HOST], [HARD_READ], [DELAY_MIN], [REMIND_DATE], [HIDE], 2, [UPD_DATE], [UPD_USER]
				FROM [dbo].[ClientMessage]
				WHERE [ID] = @ID

			UPDATE [dbo].[ClientMessage] SET
				[DELAY_MIN] = DELAY_MIN + @Setting_DELAY,
				[REMIND_DATE] = DateAdd(Minute, @Setting_DELAY, GetDate()),
				[UPD_USER] = Original_Login(),
				[UPD_DATE] = GetDate()
			WHERE [ID] = @ID;
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
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_DELAY] TO rl_client_message_r;
GO
