USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SATISFACTION_QUESTION_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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

		IF OBJECT_ID('tempdb..#report') IS NOT NULL
			DROP TABLE #report

		CREATE TABLE #report
			(
				SQ_ID		UNIQUEIDENTIFIER,
				SQ_TEXT		VARCHAR(500),
				SQ_ORDER	INT,
				SA_ID		UNIQUEIDENTIFIER,
				SA_TEXT		VARCHAR(500),
				CNT			INT
			)

		INSERT INTO #report(SQ_ID, SQ_TEXT, SQ_ORDER, SA_ID, SA_TEXT, CNT)
			SELECT
				SQ_ID, SQ_TEXT, SQ_ORDER, SA_ID, SA_TEXT,
				(
					SELECT COUNT(*)
					FROM
						dbo.ClientCall
						INNER JOIN dbo.ClientSatisfaction ON CC_ID = CS_ID_CALL
						INNER JOIN dbo.ClientSatisfactionQuestion ON CS_ID = CSQ_ID_CS
						INNER JOIN dbo.ClientSatisfactionAnswer ON CSA_ID_QUESTION = CSQ_ID
					WHERE /*CS_TYPE = 0
						AND */(CC_DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (CC_DATE <= @END OR @END IS NULL)
						AND CSA_ID_ANSWER = SA_ID
				) AS CNT
			FROM
				dbo.SatisfactionQuestion
				INNER JOIN dbo.SatisfactionAnswer ON SQ_ID = SA_ID_QUESTION
			ORDER BY SQ_ORDER, CNT DESC

		SELECT
			ROW_NUMBER() OVER(PARTITION BY SQ_ID ORDER BY SQ_ORDER, CNT DESC) AS RN,
			SQ_TEXT, SA_TEXT, CNT,
			CONVERT(VARCHAR(20),
				CASE
					WHEN TOTAL = 0 THEN 0
					ELSE ROUND(CNT / CONVERT(FLOAT, TOTAL) * 100, 2)
				END) + ' %' AS PRCNT
		FROM
			(
				SELECT
					SQ_ID, SQ_TEXT, SQ_ORDER, SA_TEXT, CNT,
					(
						SELECT SUM(CNT)
						FROM #report b
						WHERE b.SQ_ID = a.SQ_ID
					) AS TOTAL
				FROM
					#report a
			) AS o_O
		ORDER BY SQ_ORDER, CNT DESC

		IF OBJECT_ID('tempdb..#report') IS NOT NULL
			DROP TABLE #report

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SATISFACTION_QUESTION_REPORT] TO rl_satisfaction_question_report;
GO
