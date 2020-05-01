USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DUTY_PERSONAL_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@DUTY		INT = NULL
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
			DutyName,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
				WHERE a.DutyID = b.DutyID
					AND b.STATUS = 1
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
			) AS CallCount,
			(
				SELECT SUM(ClientDutyDocs)
				FROM
					dbo.ClientDutyTable b 
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
				WHERE a.DutyID = b.DutyID
					AND b.STATUS = 1
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
			) AS DocCount,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
					INNER JOIN dbo.ClientDutyResult d ON d.ID_DUTY = b.ClientDutyID
				WHERE a.DutyID = b.DutyID
					AND b.STATUS = 1
					AND d.STATUS = 1
					AND d.ANSWER = 1
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
			) AS ANS_COUNT,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
					INNER JOIN dbo.ClientDutyResult d ON d.ID_DUTY = b.ClientDutyID
				WHERE a.DutyID = b.DutyID
					AND b.STATUS = 1
					AND d.STATUS = 1
					AND d.SATISF = 0
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
			) AS SAT_COUNT,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
					INNER JOIN dbo.ClientDutyResult d ON d.ID_DUTY = b.ClientDutyID
				WHERE a.DutyID = b.DutyID
					AND b.STATUS = 1
					AND d.STATUS = 1
					AND d.SATISF = 1
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
			) AS UNSAT_COUNT,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
				WHERE a.DutyID = b.DutyID
					AND b.STATUS = 1
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.ClientDutyResult d
							WHERE d.ID_DUTY = b.ClientDutyID
								AND d.STATUS = 1
						)
			) AS NO_RESULT
		FROM dbo.DutyTable a
		WHERE (DutyID = @DUTY OR @DUTY IS NULL)
			AND EXISTS
			(
				SELECT *
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
				WHERE a.DutyID = b.DutyID
					AND b.STATUS = 1
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DUTY_PERSONAL_REPORT_NEW] TO rl_report_client_duty;
GO