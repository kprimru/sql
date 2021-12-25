USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[TEST_AUDIT_DETAIL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[TEST_AUDIT_DETAIL]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[TEST_AUDIT_DETAIL]
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

		SELECT START, PERSONAL, b.NAME, c.NOTE, c.RESULT, QST_SUCCESS AS SUCCESS_VALUE
		FROM
			Subhost.PersonalTest a
			INNER JOIN Subhost.Test b ON a.ID_TEST = b.ID
			LEFT OUTER JOIN Subhost.CheckTest c ON c.ID_TEST = a.ID
		WHERE a.ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[TEST_AUDIT_DETAIL] TO rl_subhost_test;
GO
