USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[CONTRACT_PAY_CONDITION]
	@PARAM	NVARCHAR(MAX) = NULL
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
			ServiceName AS [СИ],
			ClientFullName AS [Клиент], DistrStr AS [Дистрибутив],
			ContractPayName AS [Условие оплаты],--ContractPayDay AS [], ContractPayMonth AS [],
			COP_NAME AS [Условие оплаты в DBF]--, COP_MONTH AS [], COP_DAY AS []
		FROM
			(
				SELECT
					ClientID, ClientFullName, ServiceName, PayTypeName, ContractPayName, ContractPayDay, ContractPayMonth,
					SystemBaseName, DISTR, COMP, DistrStr
				FROM
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
					INNER JOIN dbo.ServiceTable ON ClientServiceID = ServiceID
					INNER JOIN dbo.PayTypeTable b ON a.PayTypeID = b.PayTypeID
					OUTER APPLY dbo.ClientContractPayGet(a.ClientID, NULL)
					CROSS APPLY
					(
						SELECT TOP 1 SystemBaseName, DISTR, COMP, DIstrStr
						FROM dbo.ClientDistrView WITH(NOEXPAND)
						WHERE ClientID = ID_CLIENT
						ORDER BY SystemOrder, DISTR, COMP
					) AS y
				WHERE STATUS = 1 --AND ID_HEAD IS NULL
			) AS CLIENT
			LEFT OUTER JOIN
			(
				SELECT CL_PSEDO, COP_NAME, COP_MONTH, COP_DAY, SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM
				FROM
					[DBF].[dbo.ClientTable] a
					INNER JOIN [DBF].[dbo.ClientDistrTable] b ON a.CL_ID = CD_ID_CLIENT
					INNER JOIN [DBF].[dbo.DistrView] c ON b.CD_ID_DISTR = c.DIS_ID
					INNER JOIN [DBF].[dbo.DistrServiceStatusTable] d ON d.DSS_ID = b.CD_ID_SERVICE AND DSS_REPORT = 1
					CROSS APPLY
					(
						SELECT TOP 1 COP_NAME, COP_DAY, COP_MONTH
						FROM
							[DBF].[dbo.ContractDistrTable] e
							INNER JOIN [DBF].[dbo.ContractTable] f ON f.CO_ID = e.COD_ID_CONTRACT
							INNER JOIN [DBF].[dbo.ContractPayTable] g ON g.COP_ID = CO_ID_PAY
						WHERE COD_ID_DISTR = DIS_ID AND CO_ACTIVE = 1 AND CO_ID_CLIENT = CL_ID
					) AS u
			) AS DBF ON SYS_REG_NAME = SystemBaseName AND DISTR = DIS_NUM AND COMP = DIS_COMP_NUM
		WHERE ContractPayDay <> COP_DAY OR ContractPayMonth <> COP_MONTH
		ORDER BY ServiceName, ClientFullname

	EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[CONTRACT_PAY_CONDITION] TO rl_report;
GO