USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_STAT_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT
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

		SELECT ServiceName, COUNT(*) AS ClaimCount
		FROM
			dbo.ServiceTable a
			INNER JOIN dbo.ClientClaimServiceView b ON a.ServiceID = b.ID_SERVICE
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND CLM_DATE BETWEEN @BEGIN AND @END
		GROUP BY ServiceName
		ORDER BY ServiceName

		/*
		SELECT ServiceName, ClaimCount
		FROM
			(
				SELECT
					ServiceName,
					(
						SELECT COUNT(*)
						FROM
							(
								SELECT DISTINCT CLM_ID
								FROM
									dbo.ClaimTable b
									INNER JOIN dbo.ClientTable d ON b.CLM_ID_CLIENT = d.ClientID
									INNER JOIN dbo.ClientServiceView c ON c.ID_CLIENT = b.CLM_ID_CLIENT
										AND dbo.DateOf(CLM_DATE) BETWEEN START AND FINISH
								WHERE a.ServiceID = c.ID_SERVICE
									AND d.STATUS = 1
									AND dbo.DateOf(CLM_DATE) BETWEEN @BEGIN AND @END
									AND CLM_DATE >= '20130701'

								UNION

								SELECT DISTINCT CLM_ID
								FROM
									dbo.ClaimTable b
									INNER JOIN dbo.ClientTable c ON CLM_ID_CLIENT = ClientID
								WHERE a.ServiceID = c.ClientServiceID
									AND dbo.DateOf(CLM_DATE) BETWEEN @BEGIN AND @END
									AND c.STATUS = 1
									AND CLM_DATE <= '20130701'
									AND NOT EXISTS
										(
											SELECT *
											FROM dbo.ClientServiceView
											WHERE ClientID = CLM_ID_CLIENT
												AND dbo.DateOf(CLM_DATE) BETWEEN START AND FINISH
										)
							) AS o_O

					) AS ClaimCount
				FROM dbo.ServiceTable a
				WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			) AS o_O
		WHERE ClaimCount <> 0

		ORDER BY ServiceName
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLAIM_STAT_REPORT_NEW] TO rl_report_client_tech;
GO