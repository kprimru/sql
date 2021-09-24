USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[DIN_BUH_SELECT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@OLD		INT,
	@NEW		INT,
	@REG		TINYINT,
	@CLIENT		VARCHAR(100),
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL,
	@STATUS		UNIQUEIDENTIFIER = NULL
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

		SET @END = DATEADD(DAY, 1, @END)

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				OLD_HOST	INT,
				OLD_NUM		INT,
				OLD_COMP	TINYINT,
				OLD_DISTR	VARCHAR(50),
				NEW_HOST	INT,
				NEW_NUM		INT,
				NEW_COMP	TINYINT,
				NEW_DISTR	VARCHAR(50),
				DATE		SMALLDATETIME
			)

		INSERT INTO #distr(OLD_HOST, OLD_NUM, OLD_COMP, OLD_DISTR, NEW_HOST, NEW_NUM, NEW_COMP, NEW_DISTR, DATE)
			SELECT
				2, DistrNumber, CompNumber,
				CONVERT(VARCHAR(20), DistrNumber) +
					CASE CompNumber
						WHEN 1 THEN ''
						ELSE '/' + CONVERT(VARCHAR(20), CompNumber)
					END,
				NEW_HOST, NEW_NUM, NEW_COMP,
				CONVERT(VARCHAR(20), NEW_NUM) +
					CASE NEW_COMP
						WHEN 1 THEN ''
						ELSE '/' + CONVERT(VARCHAR(20), NEW_COMP)
					END,
				DATE
			FROM
				dbo.RegNodeTable a
				INNER JOIN dbo.DistrStatus b ON a.Service = b.DS_REG
				LEFT OUTER JOIN dbo.DistrExchange c ON c.OLD_HOST = 2 AND c.OLD_NUM = DistrNumber AND c.OLD_COMP = CompNumber
			WHERE (b.DS_ID = @STATUS OR @STATUS IS NULL)
				AND a.SystemName IN ('BUH', 'BUHU')
				AND (DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (DATE < @END OR @END IS NULL)
				AND (CONVERT(VARCHAR(20), DistrNumber) LIKE CONVERT(VARCHAR(20), @OLD) + '%' OR @OLD IS NULL)
				AND (CONVERT(VARCHAR(20), NEW_NUM) LIKE CONVERT(VARCHAR(20), @NEW) + '%' OR @NEW IS NULL)
				AND (@REG = 0 OR @REG = 1 AND DATE IS NOT NULL OR @REG = 2 AND DATE IS NULL)

			UNION

			SELECT OLD_HOST, OLD_NUM, OLD_COMP,
				CONVERT(VARCHAR(20), OLD_NUM) +
				CASE OLD_COMP
					WHEN 1 THEN ''
					ELSE '/' + CONVERT(VARCHAR(20), OLD_COMP)
				END AS OLD_DISTR,
				NEW_HOST, NEW_NUM, NEW_COMP,
				CONVERT(VARCHAR(20), NEW_NUM) +
				CASE NEW_COMP
					WHEN 1 THEN ''
					ELSE '/' + CONVERT(VARCHAR(20), NEW_COMP)
				END AS NEW_DISTR,
				DATE
			FROM
				dbo.DistrExchange a
				LEFT OUTER JOIN dbo.RegNodeTable b ON a.OLD_HOST = 2 AND a.OLD_NUM = b.DistrNumber AND a.OLD_COMP = b.CompNumber
				LEFT OUTER JOIN dbo.DistrStatus c ON c.DS_REG = b.Service
				LEFT OUTER JOIN dbo.RegNodeTable d ON a.NEW_HOST = 1 AND a.NEW_NUM = d.DistrNumber AND a.NEW_COMP = d.CompNumber
				LEFT OUTER JOIN dbo.DistrStatus e ON e.DS_REG = d.Service
			WHERE (DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (DATE < @END OR @END IS NULL)
				AND (ISNULL(b.SystemName, 'BUH') IN ('BUH', 'BUHU'))
				AND (CONVERT(VARCHAR(20), OLD_NUM) LIKE CONVERT(VARCHAR(20), @OLD) + '%' OR @OLD IS NULL)
				AND (CONVERT(VARCHAR(20), NEW_NUM) LIKE CONVERT(VARCHAR(20), @NEW) + '%' OR @NEW IS NULL)
				AND (@REG = 0 OR @REG = 1 AND DATE IS NOT NULL OR @REG = 2 AND DATE IS NULL)
				AND (@STATUS IS NULL OR ISNULL(e.DS_ID, c.DS_ID) = @STATUS)


		SELECT OLD_HOST, OLD_NUM, OLD_COMP, OLD_DISTR, NEW_DISTR, DATE, Comment, ClientFullName, ManagerName, ServiceName, DS_INDEX,
			(
				SELECT MAX(UF_DATE)
				FROM
					USR.USRActiveView a
					INNER JOIN USR.USRPackage b ON a.UF_ID = b.UP_ID_USR
					INNER JOIN dbo.SystemTable c ON c.SystemID = b.UP_ID_SYSTEM
				WHERE c.HostID = OLD_HOST AND b.UP_DISTR = OLD_NUM AND b.UP_COMP = OLD_COMP
			) AS LAST_UPDATE
		FROM
			(
				SELECT DISTINCT
					OLD_HOST, OLD_NUM, OLD_COMP, OLD_DISTR, NEW_DISTR, DATE,
					CASE OLD.Service
						WHEN 2 THEN NEW.DS_INDEX
						ELSE OLD.DS_INDEX
					END AS DS_INDEX,
					CASE OLD.Service
						WHEN 2 THEN NEW.Comment
						ELSE OLD.Comment
					END AS Comment,
					CASE
						WHEN NEW_CLIENT.HostID IS NULL THEN OLD_CLIENT.ClientFullName
						ELSE NEW_CLIENT.ClientFullName
					END AS ClientFullName,
					CASE
						WHEN NEW_CLIENT.HostID IS NULL THEN OLD_CLIENT.ManagerName
						ELSE NEW_CLIENT.ManagerName
					END AS ManagerName,
					CASE
						WHEN NEW_CLIENT.HostID IS NULL THEN OLD_CLIENT.ServiceName
						ELSE NEW_CLIENT.ServiceName
					END AS ServiceName,
					CASE
						WHEN NEW_CLIENT.HostID IS NULL THEN OLD_CLIENT.ServiceID
						ELSE NEW_CLIENT.ServiceID
					END AS ServiceID,
					CASE
						WHEN NEW_CLIENT.HostID IS NULL THEN OLD_CLIENT.ManagerID
						ELSE NEW_CLIENT.ManagerID
					END AS ManagerID
				FROM
					#distr a
					LEFT OUTER JOIN
						(
							SELECT Comment, DistrNumber, CompNumber, Service, HostID, DS_INDEX
							FROM
								dbo.SystemTable b
								INNER JOIN dbo.RegNodeTable c ON c.SystemName = b.SystemBaseName
								INNER JOIN dbo.DistrStatus d ON d.DS_REG = Service
						) AS OLD ON a.OLD_HOST = OLD.HostID AND a.OLD_NUM = OLD.DistrNumber AND a.OLD_COMP = OLD.CompNumber
					LEFT OUTER JOIN
						(
							SELECT Comment, DistrNumber, CompNumber, Service, HostID, DS_INDEX
							FROM
								dbo.SystemTable b
								INNER JOIN dbo.RegNodeTable c ON c.SystemName = b.SystemBaseName
								INNER JOIN dbo.DistrStatus d ON d.DS_REG = Service
						) AS NEW ON a.NEW_HOST = NEW.HostID AND a.NEw_NUM = NEW.DistrNumber AND a.NEW_COMP = NEW.CompNumber
					LEFT OUTER JOIN
						(
							SELECT ClientFullName, DISTR, COMP, ManagerName, ServiceName, HostID, ManagerID, ServiceID
							FROM
								#distr t
								INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON t.OLD_NUM = b.DISTR AND t.OLD_COMP = b.COMP AND b.HostID = t.OLD_HOST
								INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON d.ClientID = b.ID_CLIENT
						) AS OLD_CLIENT ON a.OLD_NUM = OLD_CLIENT.DISTR AND a.OLD_COMP = OLD_CLIENT.COMP AND a.OLD_HOST = OLD_CLIENT.HostID
					LEFT OUTER JOIN
						(
							SELECT ClientFullName, DISTR, COMP, ManagerName, ServiceName, HostID, ManagerID, ServiceID
							FROM
								#distr t
								INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON t.NEW_NUM = b.DISTR AND t.NEW_COMP = b.COMP AND b.HostID = t.NEW_HOST
								INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON d.ClientID = b.ID_CLIENT
						) AS NEW_CLIENT ON a.NEW_NUM = NEW_CLIENT.DISTR AND a.NEW_COMP = NEW_CLIENT.COMP AND a.NEW_HOST = NEW_CLIENT.HostID
			) AS o_O
		WHERE (Comment LIKE @CLIENT OR ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		ORDER BY OLD_NUM, OLD_COMP

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[DIN_BUH_SELECT] TO rl_din_exchange;
GO
