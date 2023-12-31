USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[COMPLECT_UNSERVICE_SYSTEM]
	@MANAGER	INT,
	@SERVICE	INT,
	@LAST_DATE	SMALLDATETIME,
	@SHOW_COMPL	BIT	= 1
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

		IF OBJECT_ID('tempdb..#usrdata') IS NOT NULL
			DROP TABLE #usrdata

		CREATE TABLE #usrdata
			(
				ID	INT IDENTITY(1, 1),
				UD_ID_CLIENT INT,
				HostID	INT,
				SystemShortName	VARCHAR(20),
				SystemOrder		INT,
				SystemDistrNumber	INT,
				CompNumber	TINYINT,
				UP_ID_USR	INT,
				Service		INT,
				UF_CREATE	DATETIME,
				UF_DATE		DATETIME,
				UD_NAME		VARCHAR(50),
				Complect	varchar(50),
				ManagerName VarChar(100),
				ServiceName VarChar(100),
				ClientFullName VarChar(512)
			)

		INSERT INTO #usrdata
			(
				UD_ID_CLIENT, HostID, SystemShortName, SystemOrder, SystemDistrNumber, CompNumber, UP_ID_USR, Service,
				UF_CREATE, UF_DATE, UD_NAME, Complect, ManagerName, ServiceName, ClientFullName
			)
			SELECT DISTINCT
				UD_ID_CLIENT, f.HostID, f.SystemShortName, f.SystemOrder, UP_DISTR, UP_COMP, UP_ID_USR, ISNULL(Service, 1),
				UF_CREATE, UF_DATE, dbo.DistrString(s.SystemShortName, UP_DISTR, UP_COMP), Complect, ManagerName, ServiceName, ClientFullName
			FROM
				USR.USRActiveView d
				INNER JOIN dbo.SystemTable s ON d.UF_ID_SYSTEM = s.SystemID
				INNER JOIN dbo.ClientView a WITH(NOEXPAND) ON d.UD_ID_CLIENT = a.ClientID
				INNER JOIN USR.USRPackage e ON UP_ID_USR = UF_ID
				INNER JOIN dbo.SystemTable f ON f.SystemID = e.UP_ID_SYSTEM
				LEFT JOIN Reg.RegNodeSearchView g WITH(NOEXPAND) ON g.SystemBaseName = f.SystemBaseName
																AND g.DistrNumber = e.UP_DISTR
																AND g.CompNumber = e.UP_COMP
			WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (UF_DATE >= @LAST_DATE OR @LAST_DATE IS NULL)
				AND UP_TYPE <> 'NEK'
				AND f.SystemBaseCheck = 1

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #usrdata (UP_ID_USR, Service) INCLUDE (SystemShortName, SystemOrder)'
		EXEC (@SQL)

		SELECT DISTINCT UD_ID_CLIENT,
			UF_CREATE AS CreateDate,
			UF_DATE AS USRFileDate,
			REVERSE(STUFF(REVERSE(
				(
					SELECT SystemShortName + ', '
					FROM #usrdata z
					WHERE z.UP_ID_USR = d.UP_ID_USR AND z.Service = 0
					ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 2, '')
			) AS ServicedBase,
			REVERSE(STUFF(REVERSE(
				(
					SELECT
						SystemShortName +
						ISNULL('(' + CONVERT(VARCHAR(20), (
							SELECT dbo.DateOf(MAX(RPR_DATE))
							FROM dbo.RegProtocol
							WHERE RPR_OPER IN ('Отключение', 'Сопровождение отключено') AND RPR_ID_HOST = HostID AND RPR_DISTR = SystemDistrNumber AND RPR_COMP = CompNumber
						), 104) + ')', '') + ', '
					FROM #usrdata z
					WHERE z.UP_ID_USR = d.UP_ID_USR AND z.Service = 1
					ORDER BY SystemOrder FOR XML PATH('')
				)), 1, 2, '')
			) AS UnservicesBase,
			/*
			CASE @SHOW_COMPL
				WHEN 1 THEN Complect
				ELSE Complect
			END*/ UD_NAME AS ComplectNumber,
			ManagerName, ServiceName, ClientFullName
		FROM
			#usrdata d
		WHERE
			EXISTS
				(
					SELECT *
					FROM #usrdata z
					WHERE z.UP_ID_USR = d.UP_ID_USR AND z.Service = 1
				) AND
			EXISTS
				(
					SELECT *
					FROM #usrdata z
					WHERE z.UP_ID_USR = d.UP_ID_USR AND z.Service = 0
				)
		ORDER BY ManagerName, ServiceName, UD_NAME

		IF OBJECT_ID('tempdb..#usrdata') IS NOT NULL
			DROP TABLE #usrdata

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
