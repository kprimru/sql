USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DUTY_CALL_REPORT_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DUTY_CALL_REPORT_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DUTY_CALL_REPORT_NEW]
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
			CallTypeName,
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
				WHERE a.CallTypeID = b.CallTypeID
					AND (b.DutyID = @DUTY OR @DUTY IS NULL)
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
				WHERE a.CallTypeID = b.CallTypeID
					AND (b.DutyID = @DUTY OR @DUTY IS NULL)
					AND b.STATUS = 1
					AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
					AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND c.STATUS = 1
			) AS DocCount
		FROM
			dbo.CallTypeTable a
		WHERE EXISTS
			(
				SELECT *
				FROM
					dbo.ClientDutyTable b
					INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
				WHERE a.CallTypeID = b.CallTypeID
					AND (b.DutyID = @DUTY OR @DUTY IS NULL)
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
GO
GRANT EXECUTE ON [dbo].[DUTY_CALL_REPORT_NEW] TO rl_report_client_duty;
GO
