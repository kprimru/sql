USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_CONTRACT_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_CONTRACT_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_CONTRACT_CHECK]
	@PERIOD		UNIQUEIDENTIFIER,
	@MANAGER	INT,
	@SERVICE	INT
WITH EXECUTE AS OWNER
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

		DECLARE @MON	SMALLDATETIME

		SELECT @MON = START
		FROM Common.Period
		WHERE ID = @PERIOD

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		SELECT ClientID, CLientFullName, ServiceName, ManagerName, DistrStr, CL_PSEDO, CL_FULL_NAME, CK_NAME
		FROM [DBF].[dbo.ContractTable]
		INNER JOIN [DBF].[dbo.ContractKind] ON CO_ID_KIND = CK_ID
		INNER JOIN [DBF].[dbo.ContractDistrTable] ON COD_ID_CONTRACT = CO_ID
		INNER JOIN [DBF].[dbo.DistrFinancingView] ON COD_ID_DISTR = DIS_ID
		INNER JOIN [DBF].[dbo.ClientTable] ON CL_ID = CO_ID_CLIENT
		INNER JOIN [DBF].[dbo.RegNodeTable] ON RN_SYS_NAME = SYS_REG_NAME AND RN_DISTR_NUM = DIS_NUM AND RN_COMP_NUM = DIS_COMP_NUM
		INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON DISTR = DIS_NUM AND COMP = DIS_COMP_NUM AND SystemBaseName = SYS_REG_NAME
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = ID_CLIENT
		WHERE CO_ACTIVE = 1
			AND RN_SERVICE = 0
			AND CK_NAME IN ('Государственный контракт', 'Контракт на оказание услуг', 'Контракт', 'муниципальный контракт')
			AND DSS_REPORT = 1
			AND SYS_ID_SO = 1
			AND NOT EXISTS
				(
					SELECT *
					FROM [DBF].[dbo.ActDistrTable]
					INNER JOIN [DBF].[dbo.ActTable] ON ACT_ID = AD_ID_ACT
					INNER JOIN [DBF].[dbo.PeriodTable] ON PR_ID = AD_ID_PERIOD
					WHERE AD_ID_DISTR = DIS_ID
						AND PR_DATE = @MON
				)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder, DISTR, COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_CONTRACT_CHECK] TO rl_act_report;
GO
