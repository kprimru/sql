USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_MESSAGE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_MESSAGE_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_MESSAGE_GET]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Setting_DELAY_MAX	Int;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Setting_DELAY_MAX = Cast([System].[Setting@Get]('MESSAGE_DELAY_MAX') AS Int);

		SELECT
			[ID], [SENDER], [DATE], [NOTE], [HARD_READ],
			CONVERT(BIT,
				CASE
					WHEN [DELAY_MIN] >= @Setting_DELAY_MAX THEN 0
					ELSE 1
				END) AS [CAN_DELAY],
			CONVERT(BIT, 0) AS [READED],
			[ClientFullName]
		FROM [dbo].[ClientMessage] AS A
		LEFT JOIN [dbo].[ClientTable] ON [ClientID] = [ID_CLIENT]
		WHERE [RECEIVE_USER] = Original_Login()
			AND [REMIND_DATE] < GetDate()
			AND [RECEIVE_DATE] IS NULL
			AND a.[STATUS] = 1
		ORDER BY DateAdd(Minute, [DELAY_MIN], [UPD_DATE]);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_MESSAGE_GET] TO rl_client_message_r;
GO
