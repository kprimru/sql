USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_RATE_DETAIL]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX),
	@ERROR		BIT
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
			ClientID, ClientFullName, SearchGet,
			CASE
				WHEN SearchGet BETWEEN @BEGIN AND @END THEN 1
				ELSE 0
			END AS SearchMatch
		FROM
			(
				SELECT a.ClientID, ClientFullName, MAX(SearchGet) AS SearchGet
				FROM
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
					INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
					LEFT OUTER JOIN dbo.ClientSearchTable b ON a.ClientID = b.ClientID
				WHERE ClientServiceID = @SERVICE AND STATUS = 1
				GROUP BY a.ClientID, ClientFullName
			) AS o_O
		WHERE (@ERROR = 0 OR (NOT (SearchGet BETWEEN @BEGIN AND @END) OR SearchGet IS NULL))
		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_RATE_DETAIL] TO rl_service_rate;
GO
