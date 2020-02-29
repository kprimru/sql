USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Poll].[CLIENT_POLL_QUESTION]
	@ID		UNIQUEIDENTIFIER,
	@BLANK	UNIQUEIDENTIFIER
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
			ID, NAME, TP, ANS_MIN, ANS_MAX,
			CONVERT(NVARCHAR(MAX),
				CASE TP
					WHEN 0 THEN 
						(
							SELECT CONVERT(NVARCHAR(MAX), ID_ANSWER)
							FROM 
								Poll.ClientPoll z
								INNER JOIN Poll.ClientPollQuestion y ON z.ID = y.ID_POLL
								INNER JOIN Poll.ClientPollAnswer x ON x.ID_QUESTION = y.ID
							WHERE z.ID = @ID AND y.ID_QUESTION = a.ID
						)
					WHEN 1 THEN
						('<LIST>' + 
							(
								SELECT '{' + CONVERT(NVARCHAR(MAX), ID_ANSWER) + '}' AS ITEM
								FROM 
									Poll.ClientPoll z
									INNER JOIN Poll.ClientPollQuestion y ON z.ID = y.ID_POLL
									INNER JOIN Poll.ClientPollAnswer x ON x.ID_QUESTION = y.ID
								WHERE z.ID = @ID AND y.ID_QUESTION = a.ID
								FOR XML PATH('')
							)
						+ '</LIST>')
					WHEN 2 THEN
						(
							SELECT CONVERT(NVARCHAR(MAX), TEXT_ANSWER)
							FROM 
								Poll.ClientPoll z
								INNER JOIN Poll.ClientPollQuestion y ON z.ID = y.ID_POLL
								INNER JOIN Poll.ClientPollAnswer x ON x.ID_QUESTION = y.ID
							WHERE z.ID = @ID AND y.ID_QUESTION = a.ID
						)
					WHEN 3 THEN
						(
							SELECT CONVERT(NVARCHAR(MAX), INT_ANSWER)
							FROM 
								Poll.ClientPoll z
								INNER JOIN Poll.ClientPollQuestion y ON z.ID = y.ID_POLL
								INNER JOIN Poll.ClientPollAnswer x ON x.ID_QUESTION = y.ID
							WHERE z.ID = @ID AND y.ID_QUESTION = a.ID
						)
					ELSE NULL
				END
				) AS ANS
		FROM Poll.Question a
		WHERE ID_BLANK = @BLANK
		ORDER BY ORD
		/*
		0 - однозначный выбор
		1 - многозначный выбор
		2 - свободное поле для ввода
		3 - число из диапазона
		*/
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
