USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_ERROR_REASON_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_ERROR_REASON_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_ERROR_REASON_SAVE]
	@ID		UNIQUEIDENTIFIER OUTPUT,
	@TP		NVARCHAR(128),
	@NAME	NVARCHAR(128),
	@GROUP	UNIQUEIDENTIFIER,
	@TYPE	TINYINT,
	@ORD	INT
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

		IF @ID IS NULL
			INSERT INTO dbo.ClientErrorReason(TP, NAME, ID_GROUP, RS_TYPE, ORD)
				OUTPUT inserted.ID INTO @TBL
				SELECT @TP, @NAME, @GROUP, @TYPE, ISNULL((SELECT MAX(ORD) + 1 FROM dbo.ClientErrorReason WHERE TP = @TP), 1)
		ELSE
			UPDATE dbo.ClientErrorReason
			SET NAME	=	@NAME,
				ORD		=	@ORD
			WHERE ID = @ID

		IF @ID IS NULL
			SELECT @ID = ID
			FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ERROR_REASON_SAVE] TO rl_message_u;
GO
