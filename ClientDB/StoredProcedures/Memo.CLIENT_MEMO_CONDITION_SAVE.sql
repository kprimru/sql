USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_CONDITION_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@CONDITION	NVARCHAR(MAX)
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

		INSERT INTO Memo.ClientMemoConditions(ID_MEMO, CONDITION, ORD)
			SELECT
				@ID, @CONDITION,
				ISNULL(
					(
						SELECT MAX(ORD) + 1
						FROM Memo.ClientMemoConditions
						WHERE ID_MEMO = @ID
					), 1)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_CONDITION_SAVE] TO rl_client_memo_i;
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_CONDITION_SAVE] TO rl_client_memo_u;
GO
