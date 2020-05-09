USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[TEST_AUDIT_CHECK]
	@ID		UNIQUEIDENTIFIER OUTPUT,
	@TEST	UNIQUEIDENTIFIER,
	@RESULT	TINYINT,
	@NOTE	NVARCHAR(MAX)
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

		SELECT @ID = ID
		FROM Subhost.CheckTest
		WHERE ID_TEST = @TEST

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

			INSERT INTO Subhost.CheckTest(ID_TEST, RESULT, NOTE)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@TEST, @RESULT, @NOTE)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Subhost.CheckTest
			SET RESULT	=	@RESULT,
				NOTE	=	@NOTE
			WHERE ID = @ID

			DELETE
			FROM Subhost.CheckTestQuestion
			WHERE ID_TEST = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[TEST_AUDIT_CHECK] TO rl_subhost_test;
GO