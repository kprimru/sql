USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Training].[TRAINING_SCHEDULE_SELECT]
	@SUBJECT	UNIQUEIDENTIFIER	=	NULL,
	@DATE		SMALLDATETIME		=	NULL,
	@CLIENT		VARCHAR(100)		=	NULL,
	@PERSONAL	VARCHAR(100)		=	NULL,
	@SERVICE	INT					=	NULL
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

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ID INT PRIMARY KEY
			)

		IF @CLIENT IS NOT NULL OR @SERVICE IS NOT NULL
		BEGIN
			INSERT INTO #client(ID)
				SELECT ClientID
				FROM dbo.ClientTable
				WHERE (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
					AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND STATUS = 1
		END

		SELECT
			TSC_ID, TS_NAME, TSC_DATE, CONVERT(VARCHAR(20), TSC_DATE, 104) + ' ' + TS_NAME AS TSC_LOOKUP,
			(
				SELECT COUNT(*)
				FROM
					Training.SeminarSign
					INNER JOIN Training.SeminarSignPersonal ON SP_ID = SSP_ID_SIGN
				WHERE SP_ID_SEMINAR = TSC_ID
			) AS TSC_COUNT, TSC_LIMIT
		FROM
			Training.TrainingSchedule
			INNER JOIN Training.TrainingSubject ON TS_ID = TSC_ID_TS
		WHERE (TS_ID = @SUBJECT OR @SUBJECT IS NULL)
			AND (TSC_DATE = @DATE OR @DATE IS NULL)
			AND
				(
					EXISTS
						(
							SELECT *
							FROM
								#client
								INNER JOIN Training.SeminarSign ON SP_ID_CLIENT = ID
							WHERE SP_ID_SEMINAR = TSC_ID
						) OR (@CLIENT IS NULL AND @SERVICE IS NULL)
				)
			AND
				(
					EXISTS
						(
							SELECT SSP_ID
							FROM
								Training.SeminarSign
								INNER JOIN Training.SeminarSignPersonal ON SSP_ID_SIGN = SP_ID
							WHERE SP_ID_SEMINAR = TSC_ID
								AND (ISNULL(SSP_SURNAME + ' ', '') + ISNULL(SSP_NAME + ' ', '') + ISNULL(SSP_PATRON, '') + ISNULL(SSP_POS, '')) LIKE @PERSONAL

							UNION ALL

							SELECT SR_ID
							FROM Training.SeminarReserve
							WHERE SR_ID_SUBJECT = TS_ID
								AND (ISNULL(SR_SURNAME + ' ', '') + ISNULL(SR_NAME + ' ', '') + ISNULL(SR_PATRON, '') + ISNULL(SR_POS + ' ', '')) LIKE @PERSONAL
						) OR @PERSONAL IS NULL
				)
		ORDER BY TSC_DATE DESC, TS_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Training].[TRAINING_SCHEDULE_SELECT] TO rl_training_r;
GO