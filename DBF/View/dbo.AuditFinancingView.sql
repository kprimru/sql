USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[AuditFinancingView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[AuditFinancingView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[AuditFinancingView]
AS
	SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, 'Не указаны фин.установки' AS FIN_ERROR
	FROM
		dbo.ClientTable INNER JOIN
		dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID INNER JOIN
		dbo.DistrView ON DIS_ID = CD_ID_DISTR INNER JOIN
		dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.DistrFinancingTable
			WHERE DF_ID_DISTR = DIS_ID
		) AND DSS_REPORT = 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, DIS_ID, DIS_STR,
		(
			'Неверный тип сети: указан "' + SN_NAME + '", в РЦ - "' + REG_SN_NAME + '"'
		) AS FIN_ERROR
	FROM
		dbo.ClientTable INNER JOIN
		dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID INNER JOIN
		dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
		dbo.DistrFinancingTable ON DF_ID_DISTR = CD_ID_DISTR INNER JOIN
		dbo.SystemNetTable a ON SN_ID = DF_ID_NET INNER JOIN
		dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
		(
			SELECT SN_NAME as REG_SN_NAME, RN_SYS_NAME, RN_DISTR_NUM, RN_COMP_NUM
			FROM
				dbo.SystemNetCountTable INNER JOIN
				dbo.RegNodeTable ON SNC_NET_COUNT = RN_NET_COUNT AND SNC_TECH = RN_TECH_TYPE AND SNC_ODON = RN_ODON AND SNC_ODOFF = RN_ODOFF INNER JOIN
				dbo.SystemNetTable ON SN_ID = SNC_ID_SN
		) AS ttt ON	RN_SYS_NAME = SYS_REG_NAME
				AND RN_DISTR_NUM = DIS_NUM
				AND RN_COMP_NUM = DIS_COMP_NUM
	WHERE SN_NAME <> REG_SN_NAME AND DSS_REPORT = 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, DIS_ID, DIS_STR,
		(
			'Неверный тип системы: указан "' + ISNULL(SST_CAPTION, '') + '", в РЦ - "' + REG_SST_CAPTION + '"'
		) AS FIN_ERROR
	FROM
		dbo.ClientTable INNER JOIN
		dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID INNER JOIN
		dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
		dbo.DistrFinancingTable ON DF_ID_DISTR = CD_ID_DISTR INNER JOIN
		dbo.SystemTypeTable a ON SST_ID = DF_ID_TYPE INNER JOIN
		dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
		(
			SELECT SST_CAPTION AS REG_SST_CAPTION, SST_NAME as REG_SST_NAME, RN_SYS_NAME, RN_DISTR_NUM, RN_COMP_NUM
			FROM
				dbo.SystemTypeTable INNER JOIN
				dbo.RegNodeTable ON SST_NAME = RN_DISTR_TYPE
		) AS ttt ON	RN_SYS_NAME = SYS_REG_NAME
				AND RN_DISTR_NUM = DIS_NUM
				AND RN_COMP_NUM = DIS_COMP_NUM
	WHERE SST_NAME <> REG_SST_NAME AND DSS_REPORT = 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, NULL AS DIS_ID, NULL AS DIS_STR, 'Есть неразнесенные платежи' AS FIN_ERROR
	FROM
		dbo.ClientTable
	WHERE EXISTS
		(
			SELECT *
			FROM dbo.IncomeView
			WHERE IN_ID_CLIENT = CL_ID
				AND IN_REST > 0
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, 'Не указан тип оплаты по договору' AS FIN_ERROR
	FROM
		dbo.ClientTable INNER JOIN
		dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID INNER JOIN
		dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
		dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
		dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID
	WHERE DF_ID_PAY IS NULL AND DSS_REPORT = 1 AND SYS_ID_SO = 1

	UNION ALL

	SELECT NULL, NULL, NULL, NULL, 'Отсутствует прейскурант по системе "' + SYS_SHORT_NAME + '" за "' + Convert(VarChar(20), PR_DATE, 104) + '"'
	FROM dbo.SystemTable S
	CROSS JOIN dbo.PeriodTable
	WHERE PR_DATE >= DATEADD(MONTH, -1, GETDATE())
		AND SYS_ID_SO = 1
		AND NOT EXISTS
		(
			SELECT *
			FROM dbo.PriceSystemTable
			WHERE PS_ID_SYSTEM = SYS_ID
				AND PS_ID_PERIOD = PR_ID
		)
		AND EXISTS
		(
			SELECT *
			FROM dbo.PriceSystemTable PS
			INNER JOIN dbo.SystemTable SS ON PS_ID_SYSTEM = SS.SYS_ID
			WHERE PS_ID_PERIOD = PR_ID
				AND SS.SYS_ID_SO = 1
		)
		AND EXISTS
		(
			SELECT *
			FROM dbo.ClientDistrView CD
			WHERE S.SYS_ID = CD.SYS_ID
				AND DSS_REPORT = 1
		)

	/*
	UNION ALL

	SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, 'Не сформирован счет по начислению за текущий месяц' AS FIN_ERROR
	FROM
		dbo.ClientTable INNER JOIN
		dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID INNER JOIN
		dbo.DistrView ON DIS_ID = CD_ID_DISTR INNER JOIN
		dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
		dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID INNER JOIN
		dbo.PeriodTable ON DF_ID_PERIOD = PR_ID
	WHERE PR_DATE <= GETDATE() AND DSS_REPORT = 1 AND SYS_ID_SO = 1 AND DF_MON_COUNT <> 0
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.BillIXView WITH(NOEXPAND)
				WHERE BD_ID_DISTR = DIS_ID
					AND BL_ID_CLIENT = CL_ID
					AND BL_ID_PERIOD = dbo.GET_PERIOD_BY_DATE(GETDATE())
			)
	*/

	UNION ALL

	SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, Cast(PR_NAME + ' Дубликат счета (' +
			REVERSE(STUFF(REVERSE(
				(
					SELECT CL_PSEDO + ', '
					FROM
					(
						SELECT DISTINCT BL_ID_CLIENT
						FROM dbo.BillIXVIew Z WITH(NOEXPAND)
						WHERE Z.BL_ID_PERIOD = B.BL_ID_PERIOD
							AND Z.BD_ID_DISTR = B.BD_ID_DISTR
					) Z
					INNER JOIN dbo.ClientTable C ON C.CL_ID = Z.BL_ID_CLIENT
					ORDER BY CL_PSEDO
					FOR XML PATH('')
				)), 1, 2, '')) + ')' AS VarChar(4000))
	FROM
	(
		SELECT BL_ID_PERIOD, BD_ID_DISTR
		FROM dbo.BillIXVIew WITH(NOEXPAND)
		GROUP BY BL_ID_PERIOD, BD_ID_DISTR
		HAVING COUNT(*) > 1
	) B
	INNER JOIN dbo.DistrView D WITH(NOEXPAND) ON D.DIS_ID = BD_ID_DISTR
	INNER JOIN dbo.PeriodTable P ON P.PR_ID = BL_ID_PERIOD
	OUTER APPLY
	(
		SELECT TOP 1 CL_ID, CL_PSEDO
		FROM
		(
			SELECT DISTINCT BL_ID_CLIENT
			FROM dbo.BillIXVIew Z WITH(NOEXPAND)
			WHERE Z.BL_ID_PERIOD = B.BL_ID_PERIOD
				AND Z.BD_ID_DISTR = B.BD_ID_DISTR
		) Z
		INNER JOIN dbo.ClientTable C ON C.CL_ID = Z.BL_ID_CLIENT
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDistrTable
				WHERE CD_ID_DISTR = DIS_ID
					AND CD_ID_CLIENT = CL_ID
			)
	) AS C
	GO
