USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[QUALITY_STATISTIC]
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

		DECLARE @LAST SMALLDATETIME
		
		SET @LAST = dbo.DateOf(DATEADD(MONTH, -6, GETDATE()))

		DECLARE @IB_COUNT INT
		DECLARE @UNINSTALL_COUNT INT
		DECLARE @COMPLIANCE_COUNT INT
		DECLARE @CLIENT_COUNT INT
		DECLARE @RES_COUNT INT
		DECLARE @CARD_COUNT INT
		
		SELECT @IB_COUNT = COUNT(*)
		FROM 
			dbo.ClientDistrView a WITH(NOEXPAND) 
			CROSS APPLY dbo.SystemBankGet(a.SystemID, a.DistrTypeID) b
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = a.ID_CLIENT
		WHERE a.DS_REG = 0 AND c.ServiceStatusID = 2
			AND b.SystemActive = 1 AND b.InfoBankActive = 1 AND b.Required = 1
			AND ManagerName NOT IN ('Батенева', 'Исаева', 'Семченко')

		SELECT @CLIENT_COUNT = COUNT(*)
		FROM dbo.ClientView WITH(NOEXPAND) 
		WHERE ServiceStatusID = 2 
			AND ManagerName NOT IN ('Батенева', 'Исаева', 'Семченко')

		DECLARE @UNINSTALL DECIMAL(8, 4)
		DECLARE @COMPLIANCE DECIMAL(8, 4)
		DECLARE @RES	DECIMAL(8, 4)
		DECLARE @CARD DECIMAL(8, 4)
		

		IF OBJECT_ID('tempdb..#uninstall') IS NOT NULL
			DROP TABLE #uninstall
			
		CREATE TABLE #uninstall
			(
				ClientID INT, 
				Complect	VarCHAR(100),
				ManagerName VARCHAR(100), 
				ServiceName VARCHAR(100), 
				ClientFullName VARCHAR(500), 
				DisStr VARCHAR(50), 
				InfoBankShortName VARCHAR(Max), 
				InfoBankCode VARCHAR(Max), 
				LAST_DATE DATETIME, 
				UF_DATE DATETIME
			)

		INSERT INTO #uninstall
			EXEC USR.CLIENT_SYSTEM_AUDIT NULL, NULL
			
		DELETE FROM #uninstall
		WHERE ManagerName IN ('Батенева', 'Исаева', 'Семченко')
			
		SELECT @UNINSTALL_COUNT = COUNT(*)
		FROM #uninstall
			
		SELECT @UNINSTALL = CONVERT(DECIMAL(8, 4), @UNINSTALL_COUNT) * 100 / @IB_COUNT
		

		IF OBJECT_ID('tempdb..#uninstall') IS NOT NULL
			DROP TABLE #uninstall
			
		IF OBJECT_ID('tempdb..#compliance') IS NOT NULL
			DROP TABLE #compliance
			
		CREATE TABLE #compliance
			(
				ClientID			INT, 
				ClientFullName		VARCHAR(500), 
				ManagerName			VARCHAR(100), 
				ServiceName			VARCHAR(100), 
				UD_NAME				VARCHAR(50),
				InfoBankShortName	VARCHAR(50),
				DistrNumber			VARCHAR(50),
				FirstDate			SMALLDATETIME,
				UIU_DATE			SMALLDATETIME
			)
			
		INSERT INTO #compliance
			EXEC USR.USR_COMPLIANCE_LAST @LAST, NULL, NULL			
		
		DELETE FROM #compliance
		WHERE ManagerName IN ('Батенева', 'Исаева', 'Семченко')
		
		SELECT @COMPLIANCE_COUNT = COUNT(*)	
		FROM #compliance
		
		SELECT @COMPLIANCE = CONVERT(DECIMAL(8, 4), @COMPLIANCE_COUNT) * 100 / @IB_COUNT
		

		IF OBJECT_ID('tempdb..#compliance') IS NOT NULL
			DROP TABLE #compliance
			
		IF OBJECT_ID('tempdb..#res_ver') IS NOT NULL
			DROP TABLE #res_ver
			
		CREATE TABLE #res_ver
			(
				ClientID		INT,
				ClientFullName	VARCHAR(500),
				ManagerName		VARCHAR(100),
				ServiceName		VARCHAR(100),
				UD_NAME			VARCHAR(50),
				ResVersion		VARCHAR(50),
				ConsExe			VARCHAR(50),
				KDVersion		VARCHAR(50),
				UF_DATE			DATETIME,
				UF_CREATE		DATETIME
			)
			
		INSERT INTO #res_ver
			EXEC USR.RES_VERSION_CHECK NULL, NULL, NULL, NULL, 1, 0, NULL, NULL
			
		DELETE FROM #res_ver
		WHERE ManagerName IN ('Батенева', 'Исаева', 'Семченко')
			
		SELECT @RES_COUNT = COUNT(DISTINCT ClientID) FROM #res_ver
		SELECT @RES = CONVERT(DECIMAL(8, 4), @RES_COUNT) * 100 / @CLIENT_COUNT
			
		IF OBJECT_ID('tempdb..#res_ver') IS NOT NULL
			DROP TABLE #res_ver
			

		SELECT @CARD_COUNT = COUNT(DISTINCT a.ClientID)
		FROM 
			dbo.ClientCheckView a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
		WHERE b.ServiceStatusID = 2 AND TP NOT IN ('STATUS', 'SERVICE_TYPE', 'PAPPER', 'GRAPH')
			AND ManagerName NOT IN ('Батенева', 'Исаева', 'Семченко')

		SELECT @CARD = CONVERT(DECIMAL(8, 4), @CARD_COUNT) * 100 / @CLIENT_COUNT
		
		SELECT 
			@IB_COUNT AS IB_COUNT,
			@CLIENT_COUNT AS CL_COUNT,
			@UNINSTALL_COUNT AS UNINSTALL_COUNT,
			@UNINSTALL AS UNINSTALL,
			@COMPLIANCE_COUNT AS COMPLIANCE_COUNT,
			@COMPLIANCE AS COMPLIANCE,
			@RES_COUNT AS RES_COUNT,
			@RES AS RES,
			@CARD_COUNT AS CARD_COUNT,
			@CARD AS CARD
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

