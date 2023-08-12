USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_COMPLIANCE_LAST_OLD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_COMPLIANCE_LAST_OLD]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[USR_COMPLIANCE_LAST_OLD]
	@DATE		SMALLDATETIME,
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL
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

		DECLARE @COMP	INT

		SELECT @COMP = ComplianceTypeID
		FROM dbo.ComplianceTypeTable
		WHERE ComplianceTypeName = '#HOST'

		IF OBJECT_ID('tempdb..#ib') IS NOT NULL
			DROP TABLE #ib

		CREATE TABLE #ib
			(
				UD_ID		INT,
				UD_NAME		VARCHAR(50),
				CL_ID		INT,
				UF_ID		INT,
				UI_ID_BASE	INT,
				UI_DISTR	INT,
				UI_COMP		TINYINT,
				UIU_DATE	SMALLDATETIME,
				PREV_UPDATE	SMALLDATETIME,
				FIRST_DATE	SMALLDATETIME
			)

		INSERT INTO #ib
			(
				UD_ID, UD_NAME, CL_ID, UF_ID,
				UI_ID_BASE, UI_DISTR, UI_COMP,
				UIU_DATE
			)
			SELECT
				UD_ID, dbo.DistrString(s.SystemShortName, b.UD_DISTR, b.UD_COMP), UD_ID_CLIENT, UF_ID,
				UI_ID_BASE, UI_DISTR, UI_COMP,
				UI_LAST
			FROM
				[dbo].[ClientList@Get?Read]() a
				INNER JOIN USR.USRActiveView b ON UD_ID_CLIENT = WCL_ID
				INNER JOIN dbo.SystemTable s ON s.SystemID = UF_ID_SYSTEM
				INNER JOIN USR.USRIB c ON UF_ID = UI_ID_USR
				INNER JOIN dbo.ClientTable d ON UD_ID_CLIENT = ClientID
				INNER JOIN dbo.ServiceTable e ON ServiceID = ClientServiceID
				INNER JOIN dbo.ClientDistrView g WITH(NOEXPAND) ON c.UI_DISTR = g.DISTR
																AND c.UI_COMP = g.COMP
																AND g.ID_CLIENT = d.ClientID
				CROSS APPLY dbo.SystemBankGet(g.SystemId, g.DistrTypeId) f
			WHERE UI_ID_COMP = @COMP
				AND f.InfoBankID = c.UI_ID_BASE
				AND DS_REG = 0
				AND UI_LAST >= @DATE
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)

			UNION

			SELECT
				UD_ID, dbo.DistrString(s.SystemShortName, b.UD_DISTR, b.UD_COMP), UD_ID_CLIENT, UF_ID,
				UI_ID_BASE, UI_DISTR, UI_COMP,
				UI_LAST
			FROM
				[dbo].[ClientList@Get?Read]() a
				INNER JOIN USR.USRActiveView b ON UD_ID_CLIENT = WCL_ID
				INNER JOIN dbo.SystemTable s ON s.SystemID = UF_ID_SYSTEM
				INNER JOIN USR.USRIB c ON UF_ID = UI_ID_USR
				INNER JOIN dbo.ClientTable d ON UD_ID_CLIENT = ClientID
				INNER JOIN dbo.ServiceTable e ON ServiceID = ClientServiceID
				INNER JOIN dbo.DistrConditionView f ON f.InfoBankID = c.UI_ID_BASE
													AND UI_DISTR = DistrNumber
													AND UI_COMP = CompNumber
				INNER JOIN dbo.ClientDistrView g WITH(NOEXPAND) ON f.SystemID = g.SystemID
																AND c.UI_DISTR = g.DISTR
																AND c.UI_COMP = g.COMP
																AND g.ID_CLIENT = d.ClientID
			WHERE UI_ID_COMP = @COMP
				AND DS_REG = 0
				AND UI_LAST >= @DATE
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)

		IF OBJECT_ID('tempdb..#comp') IS NOT NULL
			DROP TABLE #comp

		CREATE TABLE #comp
			(
				UF_ID		INT,
				UI_ID_BASE	INT,
				UI_DISTR	INT,
				UI_COMP		INT,
				UIU_DATE	SMALLDATETIME,
				UIU_INDX	TINYINT,
				COMP		VARCHAR(20)
			)

		INSERT INTO #comp(UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE, UIU_INDX, COMP)
			SELECT
				UF_ID, a.UI_ID_BASE, a.UI_DISTR, a.UI_COMP, y.UIU_DATE, UIU_INDX,
				ISNULL(
				(
					SELECT TOP 1 ComplianceTypeName
					FROM
						USR.USRFile b
						INNER JOIN USR.USRIB c ON b.UF_ID = c.UI_ID_USR
						INNER JOIN dbo.ComplianceTypeTable d ON d.ComplianceTypeID = c.UI_ID_COMP
					WHERE b.UF_ID_COMPLECT = a.UD_ID
						AND y.UIU_DATE = c.UI_LAST
						AND c.UI_ID_BASE = z.UI_ID_BASE
						AND	c.UI_DISTR = z.UI_DISTR
						AND c.UI_COMP = z.UI_COMP
					ORDER BY ComplianceTypeOrder
				)
				, '#HOST')
			FROM #ib a
			INNER JOIN USR.USRIB z ON	z.UI_ID_BASE = a.UI_ID_BASE
									AND z.UI_DISTR = a.UI_DISTR
									AND z.UI_COMP = a.UI_COMP
									AND z.UI_ID_USR = a.UF_ID
			INNER JOIN USR.USRUpdates y ON y.UIU_ID_IB = z.UI_ID;

		--ToDo сделать через OUTER APPLY
		UPDATE a
		SET PREV_UPDATE =
			(
				SELECT UIU_DATE
				FROM #comp z
				WHERE z.UI_ID_BASE = a.UI_ID_BASE
					AND z.UI_DISTR = a.UI_DISTR
					AND z.UI_COMP = a.UI_COMP
					AND z.UF_ID = a.UF_ID
					AND z.UIU_INDX =
						(
							SELECT MIN(b.UIU_INDX)
							FROM #comp b
							WHERE b.UF_ID = z.UF_ID
								AND b.UI_ID_BASE = z.UI_ID_BASE
								AND b.UI_DISTR = z.UI_DISTR
								AND b.UI_COMP = z.UI_COMP
								AND b.UIU_INDX <> 1
								AND b.COMP IS NOT NULL
						)
			)
		FROM #ib a;

		--ToDo сделать через OUTER APPLY
		UPDATE a
		SET FIRST_DATE =
			(
				SELECT UIU_DATE
				FROM #comp b
				WHERE a.UF_ID = b.UF_ID
					AND b.UI_ID_BASE = a.UI_ID_BASE
					AND b.UI_DISTR = a.UI_DISTR
					AND b.UI_COMP = a.UI_COMP
					AND UIU_INDX =
						ISNULL(
							(
								SELECT MIN(c.UIU_INDX)
								FROM #comp c
								WHERE c.UF_ID = b.UF_ID
									AND c.UI_ID_BASE = b.UI_ID_BASE
									AND c.UI_DISTR = b.UI_DISTR
									AND c.UI_COMP = b.UI_COMP
									AND c.COMP <> '#HOST'
							),
							(
								SELECT MIN(c.UIU_INDX)
								FROM #comp c
								WHERE c.UF_ID = b.UF_ID
									AND c.UI_ID_BASE = b.UI_ID_BASE
									AND c.UI_DISTR = b.UI_DISTR
									AND c.UI_COMP = b.UI_COMP
							)
						)
			)
		FROM #ib a;

		DECLARE @SQL NVARCHAR(MAX)
		SET @SQL = 'CREATE INDEX [' + CONVERT(VARCHAR(50), NEWID()) + '] ON #ib (UD_ID, UI_ID_BASE, UI_DISTR, UI_COMP) INCLUDE (UIU_DATE)'

		EXEC (@SQL)

		SELECT
			ClientID, ClientFullName, ManagerName, ServiceName, UD_NAME, InfoBankShortName,
			dbo.DistrString(NULL, UI_DISTR, UI_COMP) AS DistrNumber,
			CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), FIRST_DATE, 112), 112) AS FIRST_DATE,
			CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), UIU_DATE, 112), 112) AS UIU_DATE
		FROM
		(
			SELECT DISTINCT UD_NAME, CL_ID, UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, FIRST_DATE, UIU_DATE
			FROM #ib a
			WHERE EXISTS
				(
					SELECT *
					FROM USR.USRFile b
					INNER JOIN USR.USRIB c ON c.UI_ID_USR = b.UF_ID
					WHERE b.UF_ID_COMPLECT = a.UD_ID
						AND c.UI_ID_BASE = a.UI_ID_BASE
						AND c.UI_DISTR = a.UI_DISTR
						AND c.UI_COMP = a.UI_COMP
						AND c.UI_ID_COMP = @COMP
						AND PREV_UPDATE = c.UI_LAST
						AND a.UF_ID <> b.UF_ID
				)

			UNION ALL

			SELECT DISTINCT UD_NAME, CL_ID, UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, FIRST_DATE, UIU_DATE
			FROM #ib a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM USR.USRFile b
					INNER JOIN USR.USRIB c ON c.UI_ID_USR = b.UF_ID
					INNER JOIN dbo.ComplianceTypeTable d ON d.ComplianceTypeID = c.UI_ID_COMP
					WHERE b.UF_ID_COMPLECT = a.UD_ID
						AND c.UI_ID_BASE = a.UI_ID_BASE
						AND c.UI_DISTR = a.UI_DISTR
						AND c.UI_COMP = a.UI_COMP
						AND PREV_UPDATE = c.UI_LAST
						AND a.UF_ID <> b.UF_ID
				)
		) AS o_O
		INNER JOIN dbo.InfoBankTable ON InfoBankID = UI_ID_BASE
		INNER JOIN dbo.ClientTable ON ClientID = CL_ID
		INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
		INNER JOIN dbo.ManagerTable ON ManagerTable.ManagerID = ServiceTable.ManagerID
		WHERE InfoBankActive = 1
		ORDER BY ManagerName, ServiceName, ClientFullName, UI_DISTR, UI_COMP, InfoBankOrder


		IF OBJECT_ID('tempdb..#ib') IS NOT NULL
			DROP TABLE #ib

		IF OBJECT_ID('tempdb..#comp') IS NOT NULL
			DROP TABLE #comp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_COMPLIANCE_LAST_OLD] TO rl_usr_compliance;
GO
