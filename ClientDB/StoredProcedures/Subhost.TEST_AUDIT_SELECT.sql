USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[TEST_AUDIT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[TEST_AUDIT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[TEST_AUDIT_SELECT]
	@TEST		UNIQUEIDENTIFIER,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@SUBHOST	UNIQUEIDENTIFIER,
	@RESULT		SMALLINT
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

		SELECT ID, NAME, PERSONAL, START, LN, RES, RES_STATUS
		FROM
			(
				SELECT
					a.ID, b.NAME, a.PERSONAL, a.START, Common.TimeSecToStr(DATEDIFF(SECOND, a.START, a.FINISH)) AS LN,
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
					CASE
						WHEN FINISH IS NULL THEN NULL
						ELSE
							CASE ISNULL((SELECT RESULT FROM Subhost.CheckTest z WHERE z.ID_TEST = a.ID), 200)
								WHEN 200 THEN NULL
								WHEN 0 THEN 0
								WHEN 1 THEN 1
								ELSE NULL
							END
					END AS RES_STATUS
				FROM
					Subhost.PersonalTest a
					INNER JOIN Subhost.Test b ON a.ID_TEST = b.ID
				WHERE (b.ID = @TEST OR @TEST IS NULL)
					AND (a.START >= @START OR @START IS NULL)
					AND (a.START < @FINISH OR @FINISH IS NULL)
					AND (a.ID_SUBHOST = @SUBHOST OR @SUBHOST IS NULL)

			) AS o_O
		WHERE (@RESULT IS NULL OR @RESULT = 0 OR @RESULT = 1 AND RES = 'Сдан' OR @RESULT = 2 AND RES = 'Не сдан')
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
GRANT EXECUTE ON [Subhost].[TEST_AUDIT_SELECT] TO rl_subhost_test;
GO
