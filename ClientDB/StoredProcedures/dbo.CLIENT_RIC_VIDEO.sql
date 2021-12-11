USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_RIC_VIDEO]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_RIC_VIDEO]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_RIC_VIDEO]
	@ID	INT
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

		SELECT 'Подписан на "Видео.Консультант" с ' + CONVERT(NVARCHAR(64), START, 104) AS TXT
		FROM dbo.ClientDelivery
		WHERE ID_CLIENT = @ID
			AND ID_DELIVERY = '25EEB199-A6DA-E511-9D3C-0007E92AAFC5'
			AND FINISH IS NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIC_VIDEO] TO rl_client_delivery_r;
GO
