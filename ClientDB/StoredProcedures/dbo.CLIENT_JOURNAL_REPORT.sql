USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_JOURNAL_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_JOURNAL_REPORT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_JOURNAL_REPORT]
	@YEAR	UNIQUEIDENTIFIER,
	@JOURNALS   VarChar(Max) = NULL
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

		DECLARE @DP	INT

		SELECT @DP = DATEPART(YEAR, START)
		FROM Common.Period
		WHERE ID = @YEAR

		SELECT
			ROW_NUMBER() OVER(ORDER BY ClientFullName, a.START) AS RN,
			ClientFullName,
			CASE
				WHEN b.ID IS NULL THEN 'с ' + CONVERT(VARCHAR(20), a.START, 104) + ' по ' + CONVERT(VARCHAR(20), a.FINISH, 104)
				ELSE b.NAME
			END AS PERIOD
		FROM
			dbo.ClientJournal a
			INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
			INNER JOIN dbo.Journal c ON c.ID = a.ID_JOURNAL
			LEFT OUTER JOIN Common.Period b ON a.START = b.START AND a.FINISH = b.FINISH
		WHERE a.STATUS = 1
			AND DATEPART(YEAR, a.START) = @DP
			AND c.DEF = 1
			AND (a.ID_JOURNAL IN (SELECT ID FROM dbo.TableGuidFromXml(@JOURNALS)) OR @JOURNALS IS NULL)
		ORDER BY ClientFullName, a.START

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_JOURNAL_REPORT] TO rl_journal_report;
GO
