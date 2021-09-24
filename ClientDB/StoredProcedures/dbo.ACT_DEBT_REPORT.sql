USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_DEBT_REPORT]
	@MONTH		UNIQUEIDENTIFIER,
	@MANAGER	INT,
	@SERVICE	INT
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
			SET @MANAGER = NULL

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		SELECT
			z.ClientID, z.CLientFullName, z.ServiceName, z.ManagerName, ContractPayName, PayTypeName, a.DistrStr/*, b.AD_TOTAL_PRICE, c.ID_PRICE,
			ISNULL(c.ID_PRICE, 0) - b.AD_TOTAL_PRICE AS DELTA*/
		FROM
			(
				SELECT
					a.ClientID, a.ClientFullName, ServiceID, ServiceName, ManagerID, ManagerName, ContractPayName, ContractPayDay, ContractPayMonth,
					PayTypeName, PayTypeMonth, DATEADD(MONTH, PayTypeMonth, @PR_DATE) AS MON_DATE
				FROM
					dbo.ClientView z WITH(NOEXPAND)
					INNER JOIN dbo.ClientTable a ON a.ClientID = z.ClientID
					INNER JOIN dbo.PayTypeTable b ON a.PayTypeID = b.PayTypeID
					OUTER APPLY dbo.ClientContractPayGet(z.ClientID, NULL)
			) AS z
			INNER JOIN dbo.ClientDistrView a WITH(NOEXPAND) ON z.ClientID = a.ID_CLIENT
			INNER JOIN dbo.DBFActView b ON a.SystemBaseName = b.SYS_REG_NAME AND a.DISTR = b.DIS_NUM AND a.COMP = b.DIS_COMP_NUM AND b.PR_DATE = MON_DATE AND b.PR_DATE = @PR_DATE
			LEFT OUTER JOIN dbo.DBFIncomeView c ON a.SystemBaseName = c.SYS_REG_NAME AND a.DISTR = c.DIS_NUM AND a.COMP = c.DIS_COMP_NUM AND c.PR_DATE = MON_DATE
		WHERE ISNULL(c.ID_PRICE, 0) <> b.AD_TOTAL_PRICE
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_DEBT_REPORT] TO rl_act_debt_report;
GO
