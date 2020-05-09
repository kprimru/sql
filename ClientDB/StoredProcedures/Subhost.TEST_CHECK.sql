USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[TEST_CHECK]
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

		IF EXISTS
			(
				SELECT *
				FROM Subhost.CheckTest
				WHERE ID_TEST = @ID
			)
			RETURN

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		DECLARE @CHECK UNIQUEIDENTIFIER

		INSERT INTO Subhost.CheckTest(ID_TEST, NOTE)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@ID, '')

		SELECT @CHECK = ID FROM @TBL

		INSERT INTO Subhost.CheckTestQuestion(ID_TEST, ID_QUESTION, RESULT, NOTE)
			SELECT
				@CHECK, a.ID,
				CASE
					WHEN b.TP = 1 THEN NULL
					WHEN b.TP IN (2, 3) THEN
						CASE
							WHEN
								(
									SELECT ID_ANSWER AS item
									FROM Subhost.PersonalTestAnswer z
									WHERE ID_QUESTION = a.ID
									ORDER BY ID_ANSWER FOR XML PATH(''), ROOT('root')
								) =
								(
									SELECT y.ID AS item
									FROM
										Subhost.TestQuestion z
										INNER JOIN Subhost.TestAnswer y ON y.ID_QUESTION = z.ID
									WHERE z.ID = b.ID AND CORRECT = 1
									ORDER BY y.ID FOR XML PATH(''), ROOT('root')
								) THEN 1
							ELSE 0
						END
					ELSE NULL
				END
				, ''
			FROM
				Subhost.PersonalTestQuestion a
				INNER JOIN Subhost.TestQuestion b ON a.ID_QUESTION = b.ID
			WHERE a.ID_TEST = @ID

		UPDATE a
		SET RESULT =
			CASE
				WHEN EXISTS
					(
						SELECT *
						FROM Subhost.CheckTestQuestion z
						WHERE z.ID_TEST = a.ID
							AND z.RESULT IS NULL
					) THEN NULL
				ELSE
					CASE
						WHEN
							(
								SELECT COUNT(*)
								FROM Subhost.CheckTestQuestion
								WHERE ID_TEST = @CHECK
									AND RESULT = 1
							)
							>=
							(
								SELECT QST_SUCCESS
								FROM
									Subhost.Test z
									INNER JOIN Subhost.PersonalTest y ON z.ID = y.ID_TEST
								WHERE y.ID = @ID
							)
							THEN 1
						ELSE 0
					END
			END
		FROM Subhost.CheckTest a
		WHERE ID = @CHECK

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[TEST_CHECK] TO rl_web_subhost;
GO