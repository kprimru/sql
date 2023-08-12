USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SEMINAR_GRAPH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SEMINAR_GRAPH]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SEMINAR_GRAPH]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SCOUNT	INT = NULL OUTPUT,
	@CCOUNT	INT = NULL OUTPUT,
	@PCOUNT	INT = NULL OUTPUT,
	@UCOUNT	INT = NULL OUTPUT
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

		SELECT a.SMONTH, a.CNT AS CL_CNT, b.CNT AS PER_CNT, c.CNT AS SEM_CNT
		FROM
			(
				SELECT dbo.MonthOf(StudyDate) AS SMONTH, COUNT(DISTINCT ClientID) AS CNT
				FROM dbo.ClientSeminarView WITH(NOEXPAND)
				WHERE StudyDate BETWEEN @BEGIN AND @END
				GROUP BY dbo.MonthOf(StudyDate)
			) AS a
			INNER JOIN
			(
				SELECT dbo.MonthOf(StudyDate) AS SMONTH, COUNT(*) AS CNT
				FROM dbo.ClientSeminarView WITH(NOEXPAND)
				WHERE StudyDate BETWEEN @BEGIN AND @END
				GROUP BY dbo.MonthOf(StudyDate)
			) AS b ON a.SMONTH = b.SMONTH
			INNER JOIN
			(
				SELECT dbo.MonthOf(StudyDate) AS SMONTH, COUNT(DISTINCT StudyDate) AS CNT
				FROM dbo.ClientSeminarView WITH(NOEXPAND)
				WHERE StudyDate BETWEEN @BEGIN AND @END
				GROUP BY dbo.MonthOf(StudyDate)
			) AS c ON a.SMONTH = c.SMONTH
		ORDER BY a.SMONTH


		SELECT @SCOUNT = COUNT(DISTINCT StudyDate)
		FROM dbo.ClientSeminarView WITH(NOEXPAND)
		WHERE StudyDate BETWEEN @BEGIN AND @END

		SELECT @CCOUNT = COUNT(DISTINCT ClientID)
		FROM dbo.ClientSeminarView WITH(NOEXPAND)
		WHERE StudyDate BETWEEN @BEGIN AND @END

		SELECT @PCOUNT = COUNT(*)
		FROM dbo.ClientSeminarView WITH(NOEXPAND)
		WHERE StudyDate BETWEEN @BEGIN AND @END

		SELECT @UCOUNT = COUNT(DISTINCT StudentFam + '+' + StudentName + '+' + StudentOtch)
		FROM dbo.ClientSeminarView WITH(NOEXPAND)
		WHERE StudyDate BETWEEN @BEGIN AND @END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SEMINAR_GRAPH] TO rl_seminar_graph;
GO
