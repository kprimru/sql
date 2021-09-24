USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_RATE_SEARCH_DETAIL]
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
			END AS SearchMatch,
				(
					SELECT TOP 1 CM_TEXT
					FROM
						dbo.ClientSearchComments z CROSS APPLY
						(
							SELECT
								x.value('@TEXT[1]', 'VARCHAR(500)') AS CM_TEXT,
								x.value('@DATE[1]', 'VARCHAR(50)') AS CM_DATE
							FROM z.CSC_COMMENTS.nodes('/ROOT/COMMENT') t(x)
						) AS o_O
					WHERE z.CSC_ID_CLIENT = t.ClientID
					ORDER BY CM_DATE DESC
			) AS Comment,
			REVERSE(STUFF(REVERSE(
				(
					SELECT SystemTypeName + ', '
					FROM
						(
							SELECT DISTINCT SystemTypeName
							FROM dbo.ClientDistrView z WITH(NOEXPAND)
							WHERE z.ID_CLIENT = t.ClientID AND DS_REG = 0
						) AS o_O
					ORDER BY SystemTypeName FOR XML PATH('')
				)), 1, 2, '')) AS SystemType
		FROM
			(
				SELECT a.ClientID, ClientFullName, MAX(SearchGetDay) AS SearchGet
				FROM
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
					INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
					LEFT OUTER JOIN dbo.ClientSearchTable b ON a.ClientID = b.ClientID
				WHERE ClientServiceID = @SERVICE
					AND STATUS = 1
					AND EXISTS
						(
							SELECT *
							FROM dbo.ClientDistrView z WITH(NOEXPAND)
							WHERE a.ClientID = z.ID_CLIENT AND DistrTypeBaseCheck = 1 AND DS_REG = 0
						)
				GROUP BY a.ClientID, ClientFullName
			) AS t
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
GRANT EXECUTE ON [dbo].[SERVICE_RATE_SEARCH_DETAIL] TO rl_service_rate;
GO
