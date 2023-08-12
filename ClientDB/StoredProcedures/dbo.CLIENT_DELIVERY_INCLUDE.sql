USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DELIVERY_INCLUDE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DELIVERY_INCLUDE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_DELIVERY_INCLUDE]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME
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

		INSERT INTO dbo.ClientDelivery(ID_CLIENT, ID_DELIVERY, EMAIL, START, NOTE)
			SELECT ID_CLIENT, ID_DELIVERY, EMAIL, @DATE, NOTE
			FROM dbo.ClientDelivery
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
GRANT EXECUTE ON [dbo].[CLIENT_DELIVERY_INCLUDE] TO rl_client_delivery_u;
GO
