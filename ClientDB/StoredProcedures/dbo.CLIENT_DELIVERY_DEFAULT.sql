USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DELIVERY_DEFAULT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DELIVERY_DEFAULT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DELIVERY_DEFAULT]
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

		SELECT TOP 1 EMAIL
		FROM dbo.ClientDelivery
		WHERE ID_DELIVERY = @ID AND @ID = '25eeb199-a6da-e511-9d3c-0007e92aafc5'
		ORDER BY UPD_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DELIVERY_DEFAULT] TO rl_client_delivery_r;
GO
