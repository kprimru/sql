USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[TEST_GENERATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[TEST_GENERATE]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [Subhost].[TEST_GENERATE]
	@SUBHOST	UNIQUEIDENTIFIER,
	@LGN		NVARCHAR(128),
	@TEST		UNIQUEIDENTIFIER,
	@ID			UNIQUEIDENTIFIER OUTPUT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Subhost.PersonalTest(ID_SUBHOST, ID_TEST, PERSONAL)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@SUBHOST, @TEST, @LGN)

		SELECT @ID = ID FROM @TBL

		INSERT INTO Subhost.PersonalTestQuestion(ID_TEST, ID_QUESTION, ORD)
			SELECT @ID, ID, ROW_NUMBER() OVER(ORDER BY NEWID())
			FROM Subhost.TestQuestion
			WHERE ID_TEST = @TEST

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[TEST_GENERATE] TO rl_web_subhost;
GO
