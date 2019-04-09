USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Poll].[POLL_QUESTION_REPORT]
	@BLANK	UNIQUEIDENTIFIER,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		CONVERT(BIT, 0) AS CHECKED,
		100 AS TP,
		QUEST, ANS, CNT, QUEST_ORD, ANS_ORD, 
		CASE TOTAL_CNT WHEN 0 THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, CNT) / TOTAL_CNT, 2) END AS PRC,
		ID_ANSWER, o_O.ID AS ID_QUESTION
	FROM 
		(			
			SELECT a.ID,
				a.NAME AS QUEST, b.NAME AS ANS, b.ID AS ID_ANSWER, 
				(
					SELECT COUNT(*)
					FROM 
						Poll.ClientPollQuestion z
						INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
						INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
					WHERE z.ID_QUESTION = a.ID AND y.ID_ANSWER = b.ID
						AND (DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (DATE <= @END OR @END IS NULL)
				) AS CNT,
				(
					SELECT COUNT(*)
					FROM 
						Poll.ClientPollQuestion z
						INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
						INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
					WHERE z.ID_QUESTION = a.ID --AND y.ID_ANSWER = b.ID
						AND (DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (DATE <= @END OR @END IS NULL)
				) AS TOTAL_CNT,
				a.ORD AS QUEST_ORD, b.ORD AS ANS_ORD
			FROM
				Poll.Question a
				INNER JOIN Poll.Answer b ON a.ID = b.ID_QUESTION
			WHERE ID_BLANK = @BLANK AND TP IN (0, 1)
		) AS o_O

	UNION ALL

	SELECT 
		CONVERT(BIT, 0) AS CHECKED,
		100 AS TP,
		QUEST, ANS, CNT, QUEST_ORD, ANS_ORD, 
		CASE TOTAL_CNT WHEN 0 THEN 0 ELSE ROUND(100 * CONVERT(FLOAT, CNT) / TOTAL_CNT, 2) END AS PRC,
		ID_ANSWER, o_O.ID AS ID_QUESTION
	FROM 
		(			
			SELECT 
				a.ID,
				a.NAME AS QUEST, TEXT_ANSWER AS ANS, NULL AS ID_ANSWER, 
				(
					SELECT COUNT(*)
					FROM 
						Poll.ClientPollQuestion z
						INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
						INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
					WHERE z.ID_QUESTION = a.ID AND y.TEXT_ANSWER = a.TEXT_ANSWER
						AND (DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (DATE <= @END OR @END IS NULL)
				) AS CNT,
				(
					SELECT COUNT(*)
					FROM 
						Poll.ClientPollQuestion z
						INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
						INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
					WHERE z.ID_QUESTION = a.ID --AND y.ID_ANSWER = b.ID
						AND (DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (DATE <= @END OR @END IS NULL)
				) AS TOTAL_CNT,
				a.ORD AS QUEST_ORD, ANS_ORD
			FROM
				(
					SELECT DISTINCT a.ID,
							a.NAME, a.ORD, 0 AS ANS_ORD,
							TEXT_ANSWER
					FROM
						Poll.Question a
						INNER JOIN Poll.ClientPollQuestion z ON z.ID_QUESTION = a.ID
						INNER JOIN Poll.ClientPollAnswer y ON y.ID_QUESTION = z.ID
						INNER JOIN Poll.ClientPoll x ON x.ID = z.ID_POLL
					WHERE a.ID_BLANK = @BLANK AND TP NOT IN (0, 1)
						AND (DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (DATE <= @END OR @END IS NULL)
				) AS a
		) AS o_O
		
	UNION ALL

	SELECT 
		CONVERT(BIT, 0) AS CHECKED,
		1 AS TP,
		'Количество анкет', '',
		COUNT(*), 0, 1, NULL, NULL, NULL
	FROM Poll.ClientPoll
	WHERE ID_BLANK = @BLANK
		AND (DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (DATE <= @END OR @END IS NULL)

	UNION ALL

	SELECT 
		CONVERT(BIT, 0) AS CHECKED,
		1 AS TP,
		'Клиентов опрошено', '',
		COUNT(DISTINCT ID_CLIENT), 0, 2, NULL, NULL, NULL
	FROM Poll.ClientPoll
	WHERE ID_BLANK = @BLANK
		AND (DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (DATE <= @END OR @END IS NULL)
		
	UNION ALL

	SELECT 
		CONVERT(BIT, 0) AS CHECKED,
		2 AS TP,
		'Даты анкет с ' + CONVERT(VARCHAR(20), MIN(DATE), 104) + ' по ' + CONVERT(VARCHAR(20), MAX(DATE), 104), '',
		COUNT(DISTINCT ID_CLIENT), 0, 2, NULL, NULL, NULL
	FROM Poll.ClientPoll
	WHERE ID_BLANK = @BLANK
		AND (DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (DATE <= @END OR @END IS NULL)

	UNION ALL

	SELECT 
		CONVERT(BIT, 0) AS CHECKED,
		3 AS TP,
		'-------------------------------------------', '',
		NULL, 0, 3, NULL, NULL, NULL

	ORDER BY QUEST_ORD, ANS_ORD
END
