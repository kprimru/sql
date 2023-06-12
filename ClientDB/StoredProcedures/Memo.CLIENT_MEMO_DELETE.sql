USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[CLIENT_MEMO_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[CLIENT_MEMO_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_DELETE]
	@ID			UNIQUEIDENTIFIER,
	@TP			SMALLINT = 1
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

		IF @TP = 1
		BEGIN
		    DELETE FROM Memo.ClientMemoSpecifications
		    WHERE Memo_Id = @ID

		    DELETE FROM Memo.ClientMemoAdditionals
		    WHERE Memo_Id = @ID

			DELETE FROM Memo.ClientMemoConditions
			WHERE ID_MEMO = @ID

			DELETE
			FROM Memo.ClientMemo
			WHERE ID = @ID
		END
		ELSE
			DELETE FROM Memo.ClientCalculation WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_DELETE] TO rl_client_memo_d;
GO
