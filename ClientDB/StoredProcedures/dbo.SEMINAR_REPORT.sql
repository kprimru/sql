USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SEMINAR_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SEMINAR_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SEMINAR_REPORT]
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL
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

		DECLARE @ID_PLACE	INT

		SELECT @ID_PLACE = LessonPlaceID
		FROM dbo.LessonPlaceTable
		WHERE LessonPlaceName = 'СТ'

		IF @BEGIN IS NULL
			SELECT @BEGIN = MIN(DATE)
			FROM dbo.ClientStudy
			WHERE ID_PLACE = @ID_PLACE

		IF @END IS NULL
			SET @END = GETDATE()

		SET @END = DATEADD(DAY, 1, @END)

		SELECT
			NOTE,
			CASE
				WHEN SEM_BEGIN_STR = SEM_END_STR THEN SEM_BEGIN_STR
				ELSE SEM_BEGIN_STR + ' - ' + SEM_END_STR
			END AS SEM_PERIOD,
			(
				SELECT COUNT(DISTINCT ID_CLIENT)
				FROM dbo.ClientStudy z
				WHERE ID_PLACE = @ID_PLACE
					AND STATUS = 1
					AND TEACHED = 1
					AND DATE >= @BEGIN
					AND DATE <= @END
					AND z.NOTE = a.NOTE
			) AS CL_COUNT,
			(
				SELECT COUNT(DISTINCT ISNULL(SURNAME, '') + ISNULL(NAME, '') + ISNULL(PATRON, ''))
				FROM
					dbo.ClientStudy z
					INNER JOIN dbo.ClientStudyPeople y ON z.ID = y.ID_STUDY
				WHERE ID_PLACE = @ID_PLACE
					AND STATUS = 1
					AND TEACHED = 1
					AND DATE >= @BEGIN
					AND DATE <= @END
					AND z.NOTE = a.NOTE
			) AS PER_COUNT
		FROM
			(
				SELECT
					NOTE, SEM_BEGIN, SEM_END,
					DATENAME(MONTH, SEM_BEGIN) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, SEM_BEGIN)) SEM_BEGIN_STR,
					DATENAME(MONTH, SEM_END) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, SEM_END)) AS SEM_END_STR
				FROM
					(
						SELECT
							NOTE, MIN(DATE) AS SEM_BEGIN, MAX(DATE) AS SEM_END
						FROM
							dbo.ClientStudy a
						WHERE ID_PLACE = @ID_PLACE
							AND STATUS = 1
							AND TEACHED = 1
							AND DATE >= @BEGIN
							AND DATE <= @END
						GROUP BY NOTE
					) AS a
			) AS a
		ORDER BY SEM_BEGIN, NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SEMINAR_REPORT] TO rl_seminar_report;
GO
