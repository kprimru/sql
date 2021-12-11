USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DELIVERY_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DELIVERY_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DELIVERY_SAVE]
	@ID		UNIQUEIDENTIFIER,
	@CLIENT	INT,
	@DELIVERY	UNIQUEIDENTIFIER,
	@EMAIL		NVARCHAR(128),
	@NOTE		NVARCHAR(MAX) = NULL
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

		IF @ID IS NULL
			INSERT INTO dbo.ClientDelivery(ID_CLIENT, ID_DELIVERY, EMAIL, START, NOTE)
				SELECT @CLIENT, @DELIVERY, @EMAIL, dbo.DateOf(GETDATE()), @NOTE
		ELSE
			UPDATE dbo.ClientDelivery
			SET	ID_DELIVERY = @DELIVERY,
				EMAIL		= @EMAIL,
				NOTE	=	@NOTE
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
GRANT EXECUTE ON [dbo].[CLIENT_DELIVERY_SAVE] TO rl_client_delivery_u;
GO
