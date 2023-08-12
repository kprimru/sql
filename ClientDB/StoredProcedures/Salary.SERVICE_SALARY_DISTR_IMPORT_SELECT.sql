USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[SERVICE_SALARY_DISTR_IMPORT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[SERVICE_SALARY_DISTR_IMPORT_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Salary].[SERVICE_SALARY_DISTR_IMPORT_SELECT]
	@MONTH		UNIQUEIDENTIFIER,
	@SERVICE	INT = NULL,
	@DISTR		INT = NULL
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

		DECLARE @START	SMALLDATETIME
		DECLARE @FINISH	SMALLDATETIME

		SELECT @START = START_REPORT, @FINISH = FINISH_REPORT
		FROM Common.Period
		WHERE ID = @MONTH

		SELECT
			CONVERT(BIT,
				CASE
					WHEN (OPER LIKE '%ЗАМЕНА%' OR OPER LIKE '%Отключение%' OR OPER LIKE 'Изм. парам.' OR OPER LIKE 'Сопровождение отключено') AND ServiceID = @SERVICE THEN 1
					ELSE 0
				END
			) AS CHECKED,
			ID_HOST, DISTR, COMP, DISTR_STR, CLIENT, OPER, OPER_NOTE, WEIGHT_OLD, WEIGHT_NEW, WEIGHT_DELTA, PRICE_OLD, PRICE_NEW, PRICE_DELTA,
			ServiceID, ServiceName
		FROM
			(
				SELECT
					RPR_ID_HOST AS ID_HOST, RPR_DISTR AS DISTR, RPR_COMP AS COMP, RPR_DATE_S AS DATE,
					Comment AS CLIENT, c.DistrStr + ' (' + NT_SHORT + ')' AS DISTR_STR, DISTR_CHANGE AS OPER_NOTE,

					REVERSE(STUFF(REVERSE(
						(
							SELECT RPR_OPER + ','
							FROM
								(
									SELECT DISTINCT RPR_OPER
									FROM dbo.RegProtocol z
									WHERE RPR_DATE_S BETWEEN @START AND @FINISH
										AND RPR_OPER IN ('Включение', 'НОВАЯ', 'ЗАМЕНА', 'Отключение', 'Изм. парам.', 'Сопровождение подключено', 'Сопровождение отключено')
										AND z.RPR_ID_HOST = a.RPR_ID_HOST
										AND z.RPR_DISTR = a.RPR_DISTR
										AND z.RPR_COMP = a.RPR_COMP
								) AS o_O
							ORDER BY RPR_OPER FOR XML PATH('')
						)), 1, 1, '')) AS OPER

					, dbo.ClientServiceDate(ID_CLIENT, RPR_DATE_S) AS ID_SERVICE
					,
					WEIGHT_OLD, WEIGHT_NEW, PRICE_OLD, PRICE_NEW,
					ISNULL(WEIGHT_NEW, 0) - ISNULL(WEIGHT_OLD, 0) AS WEIGHT_DELTA,
					ISNULL(PRICE_NEW, 0) - ISNULL(PRICE_OLD, 0) AS PRICE_DELTA

				FROM
					(
						SELECT DISTINCT RPR_ID_HOST, RPR_DISTR, RPR_COMP,
							(
								SELECT MAX(RPR_DATE_S)
								FROM dbo.RegProtocol z
								WHERE RPR_DATE_S BETWEEN @START AND @FINISH
									AND RPR_OPER IN ('Включение', 'НОВАЯ', 'ЗАМЕНА', 'Отключение', 'Изм. парам.', 'Сопровождение подключено', 'Сопровождение отключено')
									AND z.RPR_ID_HOST = a.RPR_ID_HOST
									AND z.RPR_DISTR = a.RPR_DISTR
									AND z.RPR_COMP = a.RPR_COMP
							) AS RPR_DATE_S
						FROM
							dbo.RegProtocol a
						WHERE RPR_DATE_S BETWEEN @START AND @FINISH
							AND (RPR_DISTR = @DISTR OR @DISTR IS NULL)
							AND RPR_OPER IN ('Включение', 'НОВАЯ', 'ЗАМЕНА', 'Отключение', 'Изм. парам.', 'Сопровождение подключено', 'Сопровождение отключено')
					) AS a
					INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON a.RPR_ID_HOST = c.HostID AND a.RPR_DISTR = c.DistrNumber AND a.RPR_COMP = c.CompNumber
					CROSS APPLY
						(
							SELECT
								WEIGHT_OLD, WEIGHT_NEW, PRICE_OLD, PRICE_NEW,
								CASE
									WHEN y.SystemShortName <> x.SystemShortName THEN
										CASE
											WHEN w.DistrTypeName <> r.DistrTypeName THEN 'с ' + y.SystemShortName + ' ' + w.DistrTypeName + ' на ' + x.SystemShortName + ' ' + r.DistrTypeName
											ELSE 'с ' + y.SystemShortName + ' на ' + x.SystemShortName
										END
									ELSE
										CASE
											WHEN w.DistrTypeName <> r.DistrTypeName THEN 'с ' + w.DistrTypeName + ' на ' + r.DistrTypeName
											ELSE ''
										END
								END AS DISTR_CHANGE
							FROM
								dbo.DistrPriceWeightGet(RPR_ID_HOST, RPR_DISTR, RPR_COMP, @START, @FINISH) z
								LEFT OUTER JOIN dbo.SystemTable y ON z.SYS_OLD = y.SystemID
								LEFT OUTER JOIN dbo.SystemTable x ON z.SYS_NEW = x.SystemID
								--LEFT OUTER JOIN Din.NetType w ON z.NET_OLD = w.NT_ID
								--LEFT OUTER JOIN Din.NetType r ON z.NET_NEW = r.NT_ID
								LEFT OUTER JOIN dbo.DistrTypeTable w ON z.NET_OLD = w.DistrTypeID
								LEFT OUTER JOIN dbo.DistrTypeTable r ON z.NET_NEW = r.DistrTypeID
							WHERE ISNULL(WEIGHT_OLD, 0) <> ISNULL(WEIGHT_NEW, 0) --OR ISNULL(PRICE_OLD, 0) <> ISNULL(PRICE_NEW, 0)
						) AS o_O
					LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.RPR_ID_HOST = b.HostID AND a.RPR_DISTR = b.DISTR AND a.RPR_COMP = b.COMP
			) AS a
			LEFT OUTER JOIN dbo.ServiceTable b ON a.ID_SERVICE = b.ServiceID
		WHERE NOT EXISTS
			(
				SELECT *
				FROM
					Salary.Service z
					INNER JOIN Salary.ServiceDistr y ON z.ID = y.ID_SALARY
				WHERE z.ID_MONTH = @MONTH
					AND y.ID_HOST = a.ID_HOST
					AND y.DISTR = a.DISTR
					AND y.COMP = a.COMP
			)
		ORDER BY OPER, ServiceName, CLIENT, DISTR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_DISTR_IMPORT_SELECT] TO rl_salary;
GO
