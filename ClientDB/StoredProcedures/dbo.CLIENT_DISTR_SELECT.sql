USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_SELECT]
	@CLIENTID	INT,
	@HISTORY	BIT = 0,
	@SYS_LIST	NVARCHAR(512) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

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

		DECLARE @SH_NAME VARCHAR(20)
		DECLARE @SH_CHECK BIT

		SET @SH_NAME = Maintenance.GlobalSubhostName()
		SET @SH_CHECK = Maintenance.GlobalSubhostCheck()

		SELECT @MONTH = Common.PeriodCurrent(2)

		DECLARE @MONTH_DATE SMALLDATETIME

		SELECT @MONTH_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		SET @SYS_LIST = ''
		SELECT @SYS_LIST = @SYS_LIST + SystemBaseName + ','
		FROM dbo.ClientDistrView WITH(NOEXPAND)
		WHERE ID_CLIENT = @CLIENTID
			AND DS_REG = 0

		IF @SYS_LIST <> ''
			SET @SYS_LIST = LEFT(@SYS_LIST, LEN(@SYS_LIST) - 1)

		SELECT
			STATUS,
			TP, ID, SystemOrder, ds.DistrStr, SystemTypeID, SystemTypeName, DistrTypeName, DistrTypeID, SystemID,
			ds.DS_NAME, DS_REG, DS_INDEX, D_STR,
			SystemBegin, SystemEnd, REG_ERROR, ERROR_TYPE,
			CASE WHEN DF_ID_PRICE = 6 THEN 'Прейскурант ДЕПО ' ELSE '' END +
			CASE
				WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN 'Фикс.сумма: ' + CONVERT(VARCHAR(20), CONVERT(DECIMAL(10, 2), DF_FIXED_PRICE))
				WHEN ISNULL(DF_DISCOUNT, 0) <> 0 THEN 'Скидка: ' + CONVERT(VARCHAR(20), CONVERT(INT, DF_DISCOUNT)) + ' %'
				ELSE ''
			END AS DBF_STR,
			CASE
				WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN
					CONVERT(VARCHAR(20), CONVERT(DECIMAL(10, 2), 100 * DF_FIXED_PRICE / NULLIF(ROUND(PRICE * COEF, RND), 0))) + '% от прейскуранта'
				WHEN DF_ID_PRICE = 6 THEN
					CONVERT(VARCHAR(20), CONVERT(DECIMAL(10, 2), 100 * DEPO_PRICE / NULLIF(ROUND(PRICE * COEF, RND), 0))) + '% от прейскуранта'
				ELSE ''
			END AS PRICE_STR,
			CASE
				WHEN (ISNULL(DF_FIXED_PRICE, 0) <> 0) THEN
					CONVERT(VARCHAR(20), CONVERT(DECIMAL(8, 2), ROUND((100 * (ROUND(PRICE * COEF, RND) - DF_FIXED_PRICE) / NULLIF(ROUND(PRICE * COEF, RND), 0)), 2)))
				WHEN DF_ID_PRICE = 6 THEN CONVERT(VARCHAR(20), CONVERT(DECIMAL(8, 2), ROUND((100 * (ROUND(PRICE * COEF, RND) - DEPO_PRICE) / NULLIF(ROUND(PRICE * COEF, RND), 0)), 2)))
				WHEN ISNULL(DF_DISCOUNT, 0) <> 0 THEN CONVERT(VARCHAR(20), CONVERT(INT, DF_DISCOUNT))

				ELSE CONVERT(VARCHAR(20), 0)
			END + ' %' AS REAL_DISCOUNT,
			NOTE, CASE WHEN DISCONNECT_STATUS = 1 AND DS_REG = 0 THEN 0 ELSE 1 END AS DISC_LIST,
			TransferLeft, SystemShortName,
			(
				SELECT TOP(1) Weight
				FROM dbo.Weight
				WHERE	ds.SystemBaseName	= Sys
					AND ds.DistrType		= SysType
					AND ds.NetCount			= NetCount
					AND ds.TechnolType		= NetTech
					AND ds.ODOn				= NetOdon
					AND ds.ODOff			= NetOdoff
				ORDER BY Date DESC
			) AS Weight
		FROM
			(
				SELECT
					TP, o_O.ID, SystemID, SystemBaseName, DISTR, COMP, HostID, SystemOrder, DistrStr, D_STR, SystemTypeID, SystemTypeName,
					o_O.DistrTypeName, DS_NAME, DistrType, o_O.DistrTypeID, DS_REG, DS_INDEX, SystemBegin, SystemEnd, REG_ERROR, ERROR_TYPE, o_O.STATUS,
					TransferLeft, SystemShortName, DF_ID_PRICE, DF_FIXED_PRICE, DF_DISCOUNT, DEPO_PRICE,
					w.NOTE, w.STATUS AS DISCONNECT_STATUS,
					c.PRICE,
					dbo.DistrCoef(SystemID, o_O.DistrTypeID, SystemTypeName, @MONTH_DATE) AS COEF,
					dbo.DistrCoefRound(SystemID, o_O.DistrTypeID, SystemTypeName, @MONTH_DATE) AS RND,
					NetCount AS NetCount,
					TechnolType AS TechnolType,
					ODOn AS ODOn,
					ODOff AS ODOff
				FROM
					(
						SELECT
							'CLIENT' AS TP, a.ID, a.SystemID, a.SystemBaseName, DISTR, COMP, a.HostID,
							a.SystemOrder, d.DistrType, a.DistrStr, dbo.DistrString(NULL, DISTR, COMP) AS D_STR,
							SystemTypeID, SystemTypeName, a.DistrTypeName, a.DS_NAME, a.DistrTypeID,
							a.DS_REG, a.DS_INDEX,
							(
								SELECT TOP 1 DATE
								FROM Reg.RegConnectView z
								WHERE z.RPR_ID_HOST = a.HostID
									AND z.RPR_DISTR = a.DISTR
									AND z.RPR_COMP = a.COMP
								ORDER BY DATE DESC
							) AS SystemBegin,
							(
								SELECT TOP 1 DATE
								FROM Reg.RegDisconnectView z
								WHERE z.RPR_ID_HOST = a.HostID
									AND z.RPR_DISTR = a.DISTR
									AND z.RPR_COMP = a.COMP
								ORDER BY DATE DESC
							) AS SystemEnd,
							CASE
								WHEN (@SH_CHECK = 1) AND (ISNULL(ISNULL(b.SubhostName, c.SubhostName), @SH_NAME) <> @SH_NAME) THEN 'Дистрибутив установлен у другого подхоста'
								WHEN a.SystemReg = 0 THEN ''
								WHEN b.ID IS NULL  THEN
									CASE
										WHEN c.ID IS NULL THEN 'Система не найдена в РЦ'
										ELSE 'Система заменена (' + c.SystemShortName + ')'
									END
								WHEN a.DistrTypeID <> b.DistrTypeID THEN 'Не совпадает тип сети. В РЦ - ' + b.DistrTypeName
								WHEN a.DS_ID <> b.DS_ID THEN 'Не совпадает статус системы. В РЦ - ' + b.DS_NAME
								WHEN
									ISNULL((
										SELECT ID_CLIENT
										FROM
											dbo.ClientDistrView z WITH(NOEXPAND)
											INNER JOIN dbo.RegNodeMainDistrView y WITH(NOEXPAND) ON
																			z.HostID = y.MainHostID
																			AND z.DISTR = y.MainDistrNumber
																			AND z.COMP = y.MainCompNumber
										WHERE y.SystemBaseName = a.SystemBaseName
											AND y.DistrNumber = a.DISTR
											AND y.CompNumber = a.COMP
											AND y.SubhostName = ''
									), a.ID_CLIENT) <> a.ID_CLIENT THEN 'Система зарегистрирована в комплекте клиента ' + (
										SELECT ClientFullName + ' (' + y.Complect + ')'
										FROM
											dbo.ClientDistrView z WITH(NOEXPAND)
											INNER JOIN dbo.RegNodeMainDistrView y WITH(NOEXPAND) ON
																			z.HostID = y.MainHostID
																			AND z.DISTR = y.MainDistrNumber
																			AND z.COMP = y.MainCompNumber
											INNER JOIN dbo.ClientTable x ON x.ClientID = z.ID_CLIENT
										WHERE y.SystemBaseName = a.SystemBaseName AND y.DistrNumber = a.DISTR AND y.CompNumber = a.COMP
									)
								ELSE ''
							END AS REG_ERROR,
							1 AS ERROR_TYPE,
							1 AS STATUS,
							d.TransferLeft,
							a.SystemShortName,
							d.NetCount AS NetCount,
							d.TechnolType AS TechnolType,
							d.ODOn AS ODOn,
							d.ODOff AS ODOff
						FROM
							dbo.ClientDistrView a WITH(NOEXPAND)
							LEFT OUTER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
											AND b.DistrNumber = a.DISTR
											AND b.CompNumber = a.COMP
							LEFT OUTER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = a.HostID
											AND c.DistrNumber = a.DISTR
											AND c.CompNumber = a.COMP
							LEFT OUTER JOIN dbo.RegNodeTable d ON d.ID = c.ID
						WHERE  ID_CLIENT = @CLIENTID


						UNION ALL

						SELECT
							DISTINCT 'REG' AS TP, NULL AS ID, NULL, '', c.DistrNumber, c.CompNumber, c.HostID,
							c.SystemOrder, c.DistrType, c.DistrStr, dbo.DistrString(NULL, c.DistrNumber, c.CompNumber) AS D_STR,
							NULL, '', c.DistrTypeName, c.DS_NAME, c.DistrTypeID,
							c.DS_REG, c.DS_INDEX,
							c.RegisterDate,
							NULL,
							/* пишем тут тип ошибки*/
							'Дистрибутив установлен в комплекте с системами клиента',
							2 AS ERROR_TYPE,
							1 AS STATUS,
							d.TransferLeft,
							c.SystemShortName,
							d.NetCount AS NetCount,
							d.TechnolType AS TechnolType,
							d.ODOn AS ODOn,
							d.ODOff AS ODOff
						FROM
							dbo.ClientDistrView a WITH(NOEXPAND)
							INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
											AND b.DistrNumber = a.DISTR
											AND b.CompNumber = a.COMP
							INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.Complect = b.Complect
							INNER JOIN dbo.RegNodeTable d ON d.ID = c.ID
						WHERE  ID_CLIENT = @CLIENTID AND c.DS_REG = 0 AND c.DistrType NOT IN ('NEK')
							AND c.SubhostName = Maintenance.GlobalSubhostName()
							AND NOT EXISTS
								(
									SELECT *
									FROM dbo.ClientDistrView z WITH(NOEXPAND)
									WHERE /*z.ClientID = @CLIENTID
										AND */z.HostID = c.HostID
										AND z.DISTR = c.DistrNumber
										AND z.COMP = c.CompNumber
								)

						UNION ALL

						SELECT
							'HIS' AS TP, ID, SystemID, SystemBaseName, DISTR, COMP, HostID,
							SystemOrder, NULL, dbo.DistrString(SystemShortName, DISTR, COMP), dbo.DistrString(NULL, DISTR, COMP) AS D_STR,
							SystemTypeID, SystemTypeName, DistrTypeName, '' AS DS_NAME, 0, 0 AS DS_REG, -1 AS DS_INDEX, ON_DATE, OFF_DATE, '',
							3 AS ERROR_TYPE,
							STATUS, NULL, '', '' AS NetCount, '' AS TechnolType, '' AS ODOn, '' AS ODOff
						FROM
							dbo.ClientDistr
							INNER JOIN dbo.SystemTable ON ID_SYSTEM = SystemID
							INNER JOIN dbo.DistrTypeTable ON DistrTypeID = ID_NET
							INNER JOIN dbo.SystemTypeTable ON SystemTypeID = ID_TYPE
						WHERE @HISTORY = 1 AND ID_CLIENT = @CLIENTID AND STATUS IN (3, 4)
					) AS o_O
					LEFT OUTER JOIN dbo.DBFDistrView ON SYS_REG_NAME = SystemBaseName AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					LEFT OUTER JOIN Price.SystemPrice c ON c.ID_SYSTEM = o_O.SystemID AND c.ID_MONTH = @MONTH
					LEFT OUTER JOIN dbo.DistrTypeTable b ON o_O.DistrTypeID = b.DistrTypeID
					LEFT OUTER JOIN dbo.DistrDisconnect w ON w.ID_DISTR = o_O.ID AND w.STATUS = 1
			) AS ds
		ORDER BY STATUS, DS_REG, SystemOrder, DistrStr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_SELECT] TO rl_client_distr_r;
GO