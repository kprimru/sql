USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_BASE_COMPLIANCE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_BASE_COMPLIANCE]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[USR_BASE_COMPLIANCE]
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

		DECLARE @CSTATUS	INT
		DECLARE	@SSTATUS	INT

		SET @CSTATUS = 2

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(CL_ID INT PRIMARY KEY, SNAME VARCHAR(50), MNAME VARCHAR(50))

		INSERT INTO #client(CL_ID, SNAME, MNAME)
			SELECT ClientID, ServiceName, ManagerName
			FROM dbo.ClientView WITH(NOEXPAND)
			WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ServiceStatusID = @CSTATUS OR @CSTATUS IS NULL)

		IF OBJECT_ID('tempdb..#client_system') IS NOT NULL
			DROP TABLE #client_system

		CREATE TABLE #client_system
			(
				CL_ID	INT,
				DIS_STR	VARCHAR(50),
				IB_ID	INT,
				DIS_NUM	INT,
				DIS_COMP	TINYINT,
				IB_NAME	VARCHAR(50),
				SYS_ORDER	INT,
				IB_ORDER	INT
			)

		INSERT INTO #client_system(CL_ID, DIS_STR, IB_ID, DIS_NUM, DIS_COMP, IB_NAME, SYS_ORDER, IB_ORDER)
			SELECT ID_CLIENT, DistrStr, InfoBankID, DISTR, COMP, InfoBankShortName, c.SystemOrder, InfoBankOrder
			FROM
				#client a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON b.ID_CLIENT = a.CL_ID
				CROSS APPLY dbo.SystemBankGet(b.SystemID, b.DistrTypeID) c
			WHERE b.DS_REG = 0 AND InfoBankActive = 1

			UNION

			SELECT ID_CLIENT, DistrStr, InfoBankID, DISTR, COMP, InfoBankShortName, c.SystemOrder, InfoBankOrder
			FROM
				#client a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON b.ID_CLIENT = a.CL_ID
				INNER JOIN dbo.DistrConditionView c ON c.SystemID = b.SystemID
													AND DISTR = DistrNumber
													AND COMP = CompNumber
			WHERE b.DS_REG = 0

		DECLARE @SQL VARCHAR(MAX)

		SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #client_system(DIS_NUM, IB_ID, DIS_COMP)'
		EXEC(@SQL)

		DECLARE @COMP INT

		SELECT @COMP = ComplianceTypeID
		FROM dbo.ComplianceTypeTable
		WHERE ComplianceTypeName = '#HOST'

		SELECT
			CLientFullName,	MNAME, SNAME, dbo.DistrString(s.SystemShortName, b.UD_DISTR, b.UD_COMP) AS UD_NAME,
			DIS_STR, IB_NAME, UI_LAST, UF_CREATE
		FROM
			#client_system a
			INNER JOIN #client z ON a.CL_ID = z.CL_ID
			INNER JOIN USR.USRActiveView b ON a.CL_ID = b.UD_ID_CLIENT
			INNER JOIN dbo.SystemTable s ON b.UF_ID_SYSTEM = s.SystemID
			INNER JOIN USR.USRIB ON UF_ID = UI_ID_USR AND UI_DISTR = DIS_NUM AND UI_COMP = DIS_COMP AND UI_ID_BASE = IB_ID
			INNER JOIN dbo.ClientTable ON ClientID = UD_ID_CLIENT
		WHERE UI_ID_COMP = @COMP AND STATUS = 1
		ORDER BY MName, SName, ClientFullName, UD_NAME, SYS_ORDER, DIS_NUM, DIS_COMP, IB_ORDER

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#client_system') IS NOT NULL
			DROP TABLE #client_system

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_BASE_COMPLIANCE] TO rl_usr_compliance_base;
GO
