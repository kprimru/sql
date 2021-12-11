USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[PERSONAL_TEST_ANSWER_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[PERSONAL_TEST_ANSWER_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[PERSONAL_TEST_ANSWER_SAVE]
	@QUEST	UNIQUEIDENTIFIER,
	@ANS	NVARCHAR(MAX),
	@TP		INT
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
			UPDATE Subhost.PersonalTestQuestion
			SET ANS = @ANS,
				STATUS = 2
			WHERE ID = @QUEST
		ELSE
		BEGIN
			INSERT INTO Subhost.PersonalTestAnswer(ID_QUESTION, ID_ANSWER)
				SELECT @QUEST, ID
				FROM dbo.TableGUIDFromXML(@ANS)

			UPDATE Subhost.PersonalTestQuestion
			SET STATUS = 2
			WHERE ID = @QUEST
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
GRANT EXECUTE ON [Subhost].[PERSONAL_TEST_ANSWER_SAVE] TO rl_web_subhost;
GO
