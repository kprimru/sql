USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[SERVICE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[SERVICE_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Memo].[SERVICE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(512)
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

		UPDATE Memo.Service
		SET		NAME = @NAME
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
GRANT EXECUTE ON [Memo].[SERVICE_UPDATE] TO rl_memo_service_u;
GO
