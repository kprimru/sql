USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[TEST_AUDIT_QUESTION]
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

		SELECT 
			a.ID, a.ORD, 
			CASE b.TP 
				WHEN 1 THEN a.ANS
				ELSE 
					(
						SELECT '{' + CONVERT(NVARCHAR(64), ID_ANSWER) + '}' AS '@id'
						FROM Subhost.PersonalTestAnswer z
						WHERE z.ID_QUESTION = a.ID
						ORDER BY ID_ANSWER FOR XML PATH('item'), ROOT('root')
					)
			END AS ANSWER, 
			b.QST_TEXT AS NAME, b.TP, CONVERT(SMALLINT, d.RESULT) AS RESULT, d.NOTE, b.FULL_ANSWER
		FROM 
			Subhost.PersonalTestQuestion a
			INNER JOIN Subhost.TestQuestion b ON a.ID_QUESTION = b.ID
			LEFT OUTER JOIN Subhost.CheckTest c ON c.ID_TEST = a.ID_TEST
			LEFT OUTER JOIN Subhost.CheckTestQuestion d ON d.ID_TEST = c.ID AND d.ID_QUESTION = a.ID
		WHERE a.ID_TEST = @ID
		ORDER BY ORD
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
