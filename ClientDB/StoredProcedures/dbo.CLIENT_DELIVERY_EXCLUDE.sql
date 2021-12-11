USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DELIVERY_EXCLUDE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DELIVERY_EXCLUDE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DELIVERY_EXCLUDE]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@LIST	NVARCHAR(MAX) = NULL
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

		IF @LIST IS NULL
			UPDATE dbo.ClientDelivery
			SET FINISH = @DATE
			WHERE ID = @ID
		ELSE
			UPDATE dbo.ClientDelivery
			SET FINISH = @DATE
			WHERE ID IN (SELECT ID FROM dbo.TableGUIDFromXML(@LIST))

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DELIVERY_EXCLUDE] TO rl_client_delivery_u;
GO
