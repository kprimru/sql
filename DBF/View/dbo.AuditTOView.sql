USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AuditTOView]
AS
SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, 'Отсутствует руководитель в ТО' AS TO_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON TO_ID_CLIENT = CL_ID
	WHERE NOT EXISTS
		(
			SELECT *
			FROM
				dbo.TOPersonalTable LEFT OUTER JOIN
				dbo.ReportPositionTable ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID
				AND RP_PSEDO = 'LEAD'
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, 'Отсутствует главный бухгалтер в ТО' AS TO_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON TO_ID_CLIENT = CL_ID
	WHERE NOT EXISTS
		(
			SELECT *
			FROM
				dbo.TOPersonalTable LEFT OUTER JOIN
				dbo.ReportPositionTable ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID
				AND RP_PSEDO = 'BUH'
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, 'Отсутствует ответственный в ТО' AS TO_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON TO_ID_CLIENT = CL_ID
	WHERE NOT EXISTS
		(
			SELECT *
			FROM
				dbo.TOPersonalTable LEFT OUTER JOIN
				dbo.ReportPositionTable ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID
				AND RP_PSEDO = 'RES'
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, 'Не введен фактический адрес ТО' AS TO_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON CL_ID = TO_ID_CLIENT
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.TOAddressTable
			WHERE TA_ID_TO = TO_ID
		)

	UNION ALL

	SELECT CL_ID, CL_PSEDO, TO_ID, TO_NUM, TO_NAME, 'Недопустимый символ в названии ТО' AS TO_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON CL_ID = TO_ID_CLIENT
	WHERE TO_NAME LIKE '%;%' OR TO_NAME LIKE '%' + CHAR(10) + '%' OR TO_NAME LIKE '%' + CHAR(13) + '%'		GO
