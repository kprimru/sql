USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[TEST_RESULT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[TEST_RESULT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[TEST_RESULT_SELECT]
	@SUBHOST	UNIQUEIDENTIFIER,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME
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

		SET @FINISH = DATEADD(DAY, 1, @FINISH)

		SELECT
			a.ID, b.NAME, PERSONAL, START, FINISH,
			Common.TimeSecToStr(DATEDIFF(SECOND, a.START, a.FINISH)) AS LN,
			(
				SELECT COUNT(*)
				FROM Subhost.PersonalTestQuestion z
				WHERE z.ID_TEST = a.ID
			) AS QST_CNT,
			(
				SELECT COUNT(*)
				FROM
					Subhost.CheckTest z
					INNER JOIN Subhost.CheckTestQuestion y ON z.ID = y.ID_TEST
				WHERE z.ID_TEST = a.ID
					AND y.RESULT = 1
			) AS RIGHT_CNT,
			CASE
				WHEN FINISH IS NULL THEN 'Досдать'
				ELSE
					CASE ISNULL((SELECT RESULT FROM Subhost.CheckTest z WHERE z.ID_TEST = a.ID), 200)
						WHEN 200 THEN 'Не проверен'
						WHEN 0 THEN 'Не сдан'
						WHEN 1 THEN 'Сдан'
						ELSE 'Неизвестно'
					END
			END AS RES,
			(
				SELECT TOP 1 z.NOTE
				FROM
					Subhost.CheckTest z
				WHERE z.ID_TEST = a.ID
			) AS RESULT_NOTE
		FROM
			Subhost.PersonalTest a
			INNER JOIN Subhost.Test b ON a.ID_TEST = b.ID
		WHERE a.ID_SUBHOST = @SUBHOST
			AND (START >= @START OR @START IS NULL)
			AND (START < @FINISH OR @FINISH IS NULL)
			AND FINISH IS NOT NULL
		ORDER BY START DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[TEST_RESULT_SELECT] TO rl_web_subhost;
GO
