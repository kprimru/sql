USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CONTROL_DOCUMENT_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@SUBHOST	UNIQUEIDENTIFIER,
	@CNT		INT
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

		IF @SERVICE IS NOT NULL
		BEGIN
			SET @MANAGER = NULL
			SET @SUBHOST = NULL
		END

		IF @SUBHOST IS NOT NULL
		BEGIN
			SET @MANAGER = NULL
			SET @SERVICE = NULL
		END

		DECLARE @SH_REG VARCHAR(20)

		SELECT @SH_REG = SH_REG
		FROM dbo.Subhost
		WHERE SH_ID = @SUBHOST

		IF @BEGIN IS NULL
			SELECT @BEGIN = MIN(DATE_S)
			FROM dbo.ControlDocument

		IF @END IS NULL
			SELECT @END = MAX(DATE_S)
			FROM dbo.ControlDocument

		IF OBJECT_ID('tempdb..#docs') IS NOT NULL
			DROP TABLE #docs

		CREATE TABLE #docs
			(
				TP		TINYINT,
				ClientID	INT,
				ClientName	VARCHAR(500),
				DisStr		VARCHAR(100),
				Manager		VARCHAR(100),
				ServiceName	VARCHAR(100),
				InfoBank	VARCHAR(50),
				CNT			INT
			)

		INSERT INTO #docs(TP, ClientID, ClientName, DisStr, Manager, ServiceName, InfoBank, CNT)
			SELECT TP, ClientID, ClientName, DisStr, Manager, ServiceName, InfoBankShortName, COUNT(DISTINCT IB_NUM) AS CNT
			FROM
				(
					SELECT
						CASE
							WHEN ClientID IS NULL THEN 1
							ELSE 2
						END AS TP,
						ClientID, ISNULL(CLientFullname, Comment) AS ClientName,
						dbo.DistrSrting(c.SystemShortName, a.DISTR, a.COMP) AS DisStr,
						ISNULL(ManagerName, SubhostName) AS Manager,
						ServiceName,
						InfoBankShortName, IB_NUM
					FROM
						dbo.ControlDocument a
						INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
						INNER JOIN dbo.SystemTable c ON c.SystemID = b.SystemID AND a.SYS_NUM = c.SystemNumber
						INNER JOIN dbo.InfoBankTable f ON f.InfoBankName = a.IB
						LEFT OUTER JOIN dbo.ClientDistrView d WITH(NOEXPAND) ON d.DISTR = a.DISTR AND d.COMP = a.COMP AND d.HostID = c.HostID
						LEFT OUTER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = d.ID_CLIENT
					WHERE DATE_S >= @BEGIN
						AND DATE_S <= @END
						AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
						AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
						AND (SubhostName = @SH_REG OR @SH_REG IS NULL)
				) AS o_O
			GROUP BY TP, ClientID, ClientName, DisStr, Manager, ServiceName, InfoBankShortName

		IF @CNT IS NOT NULL
			DELETE FROM #docs WHERE CNT < @CNT

		SELECT DISTINCT TP, ClientID, ClientName, DisStr, Manager, ServiceName,
			REVERSE(STUFF(REVERSE(
				(
					SELECT InfoBank + ' (' + CONVERT(VARCHAR(20), CNT) + '), '
					FROM #docs b
					WHERE a.TP = b.TP
						AND a.ClientName = b.ClientName
						AND a.DisStr = b.DisStr
					ORDER BY CNT DESC FOR XML PATH('')
				)
			), 1, 2, '')) AS IB
		FROM #docs a
		ORDER BY TP, Manager, ServiceName, ClientName, DisStr

		IF OBJECT_ID('tempdb..#docs') IS NOT NULL
			DROP TABLE #docs

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTROL_DOCUMENT_REPORT] TO rl_control_document_report;
GO