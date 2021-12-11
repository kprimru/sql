USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_MAIL_GREET_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_MAIL_GREET_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[WEB_MAIL_GREET_SELECT]
	@ID	UNIQUEIDENTIFIER = NULL
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
			P.[ID], P.[PSEDO],
			P.[EMAIL],
			'Запись на ' + T.[Name] AS SUBJ,
			'no-reply@kprim.ru' AS FROM_ADDRESS,
			'ООО Базис' AS FROM_NAME,
			[Seminar].[Template@Get](P.[ID], 'GREET') AS MAIL_BODY
		FROM [Seminar].[Personal]               AS P
		INNER JOIN [Seminar].[Schedule]         AS S ON S.[ID] = P.[ID_SCHEDULE]
		INNER JOIN [Seminar].[Schedules->Types] AS T ON T.[ID] = S.[Type_Id]
		WHERE S.[WEB] = 1
		    AND P.[PSEDO] IS NOT NULL
		    AND P.[EMAIL] IS NOT NULL
			AND P.[STATUS] = 1
			AND
				(
					P.ID = @ID
					OR
					@ID IS NULL
					AND P.[MSG_SEND] IS NULL
				);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[WEB_MAIL_GREET_SELECT] TO rl_seminar_web;
GO
