﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[DISCOUNT_SA_SK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[DISCOUNT_SA_SK]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[DISCOUNT_SA_SK]
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

		DECLARE @MONTH UNIQUEIDENTIFIER

		SELECT @MONTH = Common.PeriodCurrent(2)

		DECLARE @MONTH_DATE	SMALLDATETIME

		SELECT @MONTH_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		SELECT
			rnsv.DistrStr AS [Дистрибутив], SST_SHORT AS [Тип системы], NT_SHORT AS [Тип сети], Comment AS [Клиент], MIN(rpcv.DATE) AS [Дата регистрации],
			CONVERT(DECIMAL(8, 2),
				CASE
					WHEN (ISNULL(DF_FIXED_PRICE, 0) <> 0) THEN
						CONVERT(DECIMAL(8, 2), ROUND((100 * (ROUND(PRICE * COEF, RND) - DF_FIXED_PRICE) / NULLIF(ROUND(PRICE * COEF, RND), 0)), 2))
					WHEN DF_ID_PRICE = 6 THEN
						CONVERT(DECIMAL(8, 2), ROUND((100 * (ROUND(PRICE * COEF, RND) - DEPO_PRICE) / NULLIF(ROUND(PRICE * COEF, RND), 0)), 2))
					WHEN ISNULL(DF_DISCOUNT, 0) <> 0 THEN
						DF_DISCOUNT
					ELSE 0
				END) AS [Размер скидки],
			DATEADD(MONTH,
					CASE SST_SHORT
						WHEN 'С.А' THEN 18
						ELSE 24
					END, DATE) AS [Скидка действует до],
			DATEDIFF(DAY, GETDATE(),
				DATEADD(MONTH,
					CASE SST_SHORT
						WHEN 'С.А' THEN 18
						ELSE 24
					END, DATE)) AS [Осталось дней],
			CASE SST_SHORT
				WHEN ('С.К2') THEN /*CONVERT(NVARCHAR, */DATEADD(MONTH, 18, DATE)--)
				WHEN ('С.И') THEN /*CONVERT(NVARCHAR, */DATEADD(MONTH, 18, DATE)--)
				ELSE NULL
			END AS [Скидка РИЦ]
		FROM
			(
				SELECT
					/*ClientID, ClientFullName, ManagerName, ServiceName,*/ DistrStr,/* SystemTypeName,*/ DF_DISCOUNT, DF_FIXED_PRICE,
					DF_ID_PRICE,
					dbo.DistrCoef(SystemID, DistrTypeID, SystemTypeName, @MONTH_DATE) AS COEF,
					dbo.DistrCoef(SystemID, DistrTypeID, SystemTypeName, @MONTH_DATE) AS RND,
					PRICE, DEPO_PRICE, DISTR, COMP
				FROM
					dbo.ClientView a WITH(NOEXPAND)
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
					INNER JOIN dbo.DBFDistrFinancingView e ON SYS_REG_NAME = b.SystemBaseName
																		AND DIS_NUM = b.DISTR
																		AND DIS_COMP_NUM = b.COMP
					INNER JOIN [Price].[Systems:Price@Get](GetDate()) g ON [System_Id] = SystemID
			) AS o_O
			INNER JOIN Reg.RegNodeSearchView rnsv WITH(NOEXPAND) ON rnsv.DistrNumber = o_O.DISTR AND rnsv.CompNumber=o_O.COMP
			INNER JOIN Reg.RegProtocolConnectView rpcv WITH(NOEXPAND) ON rnsv.HostID = rpcv.RPR_ID_HOST AND rnsv.DistrNumber = rpcv.RPR_DISTR AND rnsv.CompNumber = rpcv.RPR_COMP
		WHERE
			SST_SHORT IN ('С.А', 'С.К2', 'С.К1', 'С.И') AND
			DS_REG=0

		GROUP BY rnsv.DistrStr, SST_SHORT, NT_SHORT, Comment, rnsv.SystemOrder, DF_DISCOUNT, DF_FIXED_PRICE, PRICE, COEF, RND, DF_ID_PRICE, DEPO_PRICE, DATE
		ORDER BY [Осталось дней], Comment/*, SystemOrder, DistrStr, EXIST*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[DISCOUNT_SA_SK] TO rl_report;
GO
