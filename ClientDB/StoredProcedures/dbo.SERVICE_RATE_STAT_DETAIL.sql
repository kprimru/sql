USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_RATE_STAT_DETAIL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_RATE_STAT_DETAIL]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_RATE_STAT_DETAIL]
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

		DECLARE @MONTH TABLE (MID SMALLINT, MBEGIN SMALLDATETIME, MEND SMALLDATETIME)

		INSERT INTO @MONTH(MID, MBEGIN, MEND)
			SELECT MID, MBEGIN, MEND
			FROM dbo.MonthDates(@BEGIN, @END)

		IF OBJECT_ID('tempdb..#clientlist') IS NOT NULL
			DROP TABLE #clientlist

		CREATE TABLE #clientlist(CL_ID INT PRIMARY KEY)

		INSERT INTO #clientlist(CL_ID)
			SELECT ClientID
			FROM
				dbo.ClientTable a
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
				INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientKind_Id
			WHERE ClientServiceID = @SERVICE
				AND STATUS = 1
				AND EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE a.ClientID = z.ID_CLIENT AND DistrTypeBaseCheck = 1 AND DS_REG = 0
					)

		SELECT
			ClientID, ClientFullName, LostStat,
			CASE
				WHEN LostStat IS NULL THEN 1
				ELSE 0
			END AS StatMatch
		FROM
			(
				SELECT
					ClientID, ClientFullName,
					REVERSE(STUFF(REVERSE((
							SELECT 'С ' + CONVERT(VARCHAR(20), MBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), MEND, 104) + ', '
							FROM @MONTH
							WHERE  NOT EXISTS
								(
									SELECT *
									FROM
										dbo.ClientStatView z WITH(NOEXPAND)
									WHERE z.ClientID = a.CL_ID
										AND DATE_S BETWEEN MBEGIN AND MEND
								)
							ORDER BY MID FOR XML PATH('')
						)), 1, 2, '')) AS LostStat
				FROM
					#clientlist a
					INNER JOIN dbo.ClientTable ON CL_ID = ClientID
			) AS o_O
		WHERE (@ERROR = 0 OR LostStat IS NOT NULL)
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
GRANT EXECUTE ON [dbo].[SERVICE_RATE_STAT_DETAIL] TO rl_service_rate;
GO
