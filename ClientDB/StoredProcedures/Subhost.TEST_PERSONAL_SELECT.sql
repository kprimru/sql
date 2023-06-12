USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[TEST_PERSONAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[TEST_PERSONAL_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[TEST_PERSONAL_SELECT]
	@SUBHOST	UNIQUEIDENTIFIER,
	@LGN		NVARCHAR(128)
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
			a.ID, b.NAME, a.START, a.FINISH, Common.TimeSecToStr(DATEDIFF(SECOND, a.START, a.FINISH)) AS LN,
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
		WHERE ID_SUBHOST = @SUBHOST
			AND PERSONAL = @LGN
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
GRANT EXECUTE ON [Subhost].[TEST_PERSONAL_SELECT] TO rl_web_subhost;
GO
