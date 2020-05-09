USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[TEST_AUDIT_ANSWER]
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

		SELECT c.ID, a.ID AS ID_QUESTION, ANS_TEXT AS NAME, c.CORRECT
		FROM
			Subhost.PersonalTestQuestion a
			--INNER JOIN Common.Question b ON a.ID_QUESTION = b.ID
			INNER JOIN Subhost.TestAnswer c ON c.ID_QUESTION = a.ID_QUESTION
		WHERE ID_TEST = @ID
		ORDER BY NEWID()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[TEST_AUDIT_ANSWER] TO rl_subhost_test;
GO