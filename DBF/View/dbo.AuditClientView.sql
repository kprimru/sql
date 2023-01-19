USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[AuditClientView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[AuditClientView]  AS SELECT 1')
GO

ALTER VIEW [dbo].[AuditClientView]
AS
	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Отсутствует руководитель клиента' AS CL_ERROR
	FROM 
		dbo.ClientTable
	WHERE NOT EXISTS
			(
				SELECT *
				FROM
					dbo.ClientPersonalTable LEFT OUTER JOIN
					dbo.ReportPositionTable ON RP_ID = PER_ID_REPORT_POS
				WHERE PER_ID_CLIENT = CL_ID
					AND RP_PSEDO = 'LEAD'
			)

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Отсутствует юридический адрес' AS CL_ERROR
	FROM 
		dbo.ClientTable
	WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientAddressTable
				WHERE CA_ID_CLIENT = CL_ID
					AND CA_ID_TYPE = 1
			)

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Отсутствует текущий договор' AS CL_ERROR
	FROM dbo.ClientTable a
	WHERE EXISTS
		(
			SELECT *
			FROM
				dbo.ClientDistrView b
			WHERE DSS_REPORT = 1 AND CD_ID_CLIENT = CL_ID
		) AND
		NOT EXISTS (
			SELECT *
			FROM dbo.ContractTable e
			WHERE e.CO_ID_CLIENT = a.CL_ID AND CO_ACTIVE = 1
		)

	UNION ALL

	SELECT
		NULL AS CL_ID, NULL AS CL_PSEDO, NULL AS CL_FULL_NAME, NULL AS CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Дистрибутив не распределен клиенту' AS CL_ERROR
	FROM dbo.DistrView WITH(NOEXPAND)
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientDistrTable
			WHERE CD_ID_DISTR = DIS_ID
		)
		AND DIS_ACTIVE = 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Дистрибутив не распределен в ТО' AS CL_ERROR
	FROM
		dbo.DistrView a WITH(NOEXPAND) INNER JOIN
		dbo.ClientDistrTable ON DIS_ID = CD_ID_DISTR INNER JOIN
		dbo.ClientTable ON CL_ID = CD_ID_CLIENT
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.TODistrTable
			WHERE TD_ID_DISTR = DIS_ID
		)
		AND EXISTS
		(
			SELECT *
			FROM dbo.ClientDistrTable
			WHERE CD_ID_DISTR = DIS_ID
		)
		AND DIS_ACTIVE = 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		TO_ID, TO_NUM,
		DIS_ID, DIS_STR,
		'Дистрибутив клиента разнесен в ТО не принадлежащую данному клиенту' AS CL_ERROR
	FROM
		dbo.DistrView WITH(NOEXPAND) INNER JOIN
		dbo.TODistrTable ON TD_ID_DISTR = DIS_ID INNER JOIN
		dbo.ClientDistrTable ON CD_ID_DISTR = DIS_ID INNER JOIN
		dbo.ClientTable ON CL_ID = CD_ID_CLIENT INNER JOIN
		dbo.TOTable ON TO_ID = TD_ID_TO
	WHERE TO_ID_CLIENT <> CL_ID

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Дистрибутив не указан ни в одном действующем договоре' AS CL_ERROR
	FROM
		dbo.DistrView a WITH(NOEXPAND) LEFT OUTER JOIN
		dbo.ClientDistrTable b ON CD_ID_DISTR = DIS_ID LEFT OUTER JOIN
		dbo.DistrServiceStatusTable c ON DSS_ID = CD_ID_SERVICE LEFT OUTER JOIN
		dbo.ClientTable d ON CL_ID = CD_ID_CLIENT LEFT OUTER JOIN
		dbo.TODistrTable ON TD_ID_DISTR = DIS_ID
	WHERE DIS_ACTIVE = 1 AND DSS_REPORT = 1 AND
		NOT EXISTS
			(
				SELECT *
				FROM
					dbo.ContractTable INNER JOIN
					dbo.ContractDistrTable ON CO_ID = COD_ID_CONTRACT
				WHERE CO_ID_CLIENT = CL_ID AND CO_ACTIVE = 1 AND COD_ID_DISTR = DIS_ID
			)
	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Дистрибутив указан более чем в одном действующем договоре' AS CL_ERROR
	FROM
		dbo.DistrView a WITH(NOEXPAND) LEFT OUTER JOIN
		dbo.ClientDistrTable b ON CD_ID_DISTR = DIS_ID LEFT OUTER JOIN
		dbo.DistrServiceStatusTable c ON DSS_ID = CD_ID_SERVICE LEFT OUTER JOIN
		dbo.ClientTable d ON CL_ID = CD_ID_CLIENT LEFT OUTER JOIN
		dbo.TODistrTable ON TD_ID_DISTR = DIS_ID
	WHERE DIS_ACTIVE = 1 AND DSS_REPORT = 1 AND
			(
				SELECT COUNT(*)
				FROM
					dbo.ContractTable INNER JOIN
					dbo.ContractDistrTable ON CO_ID = COD_ID_CONTRACT
				WHERE CO_ID_CLIENT = CL_ID AND CO_ACTIVE = 1
					AND COD_ID_DISTR = DIS_ID
			) > 1

	UNION ALL
/*
	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Признак подхоста на рег.узле и в базе не совпадают' AS CL_ERROR
	FROM
		dbo.ClientDistrView			a
		INNER JOIN dbo.ClientTable	b	on	a.cd_id_client=b.cl_id
		INNER JOIN dbo.SubhostTable	c	on	b.cl_id_subhost=c.sh_id
		INNER JOIN dbo.SystemTable	d	on	a.sys_id=d.sys_id
		INNER JOIN dbo.RegnodeTable	e	on	a.dis_num=e.rn_distr_num
									and d.sys_reg_name=e.rn_sys_name
									and a.dis_comp_num=e.rn_comp_num
	WHERE rn_subhost != sh_subhost AND RN_SERVICE = 0

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Названия подхостов на рег.узле и в базе не совпадают' AS CL_ERROR
	FROM
		dbo.ClientDistrView			a
		INNER JOIN dbo.ClientTable	b	on	a.cd_id_client=b.cl_id
		INNER JOIN dbo.SubhostTable	c	on	b.cl_id_subhost=c.sh_id
		INNER JOIN dbo.SystemTable	d	on	a.sys_id=d.sys_id
		INNER JOIN dbo.RegnodeTable	e	on	a.dis_num=e.rn_distr_num
									and d.sys_reg_name=e.rn_sys_name
									and a.dis_comp_num=e.rn_comp_num
	WHERE rn_comment NOT LIKE '%' + sh_lst_name + '%' AND RN_SERVICE = 0

	UNION ALL
*/
	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Неверное название подхоста на регузле' AS CL_ERROR
	FROM
		dbo.ClientDistrView			a
		INNER JOIN dbo.ClientTable	b	on	a.cd_id_client=b.cl_id
		INNER JOIN dbo.SystemTable	d	on	a.sys_id=d.sys_id
		INNER JOIN dbo.RegnodeTable	e	on	a.dis_num=e.rn_distr_num
									and d.sys_reg_name=e.rn_sys_name
									and a.dis_comp_num=e.rn_comp_num
	WHERE RN_COMMENT LIKE '(%'
		AND NOT EXISTS
		(
			SELECT *
			FROM dbo.SubhostTable
			WHERE RN_COMMENT LIKE '(' + SH_LST_NAME + ')%'
		)

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		DIS_ID, DIS_STR,
		'Неверный признак подхоста на рег.узле' AS CL_ERROR
	FROM
		dbo.ClientDistrView			a
		INNER JOIN dbo.ClientTable	b	on	a.cd_id_client=b.cl_id
		INNER JOIN dbo.SystemTable	d	on	a.sys_id=d.sys_id
		INNER JOIN dbo.RegnodeTable	e	on	a.dis_num=e.rn_distr_num
									and d.sys_reg_name=e.rn_sys_name
									and a.dis_comp_num=e.rn_comp_num
	WHERE e.RN_COMPLECT IS NOT NULL
		AND (
			SELECT TOP 1 SH_SUBHOST
			FROM dbo.SubhostTable
			WHERE (RN_COMMENT LIKE '(' + SH_LST_NAME + ')%' AND SH_LST_NAME <> '')
				OR (RN_COMMENT NOT LIKE '(%' AND SH_LST_NAME = '')

		) <> RN_SUBHOST

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		TO_ID, TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Отсутствует руководитель в ТО' AS CL_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON TO_ID_CLIENT = CL_ID
	WHERE TO_REPORT = 1
		AND NOT EXISTS
		(
			SELECT *
			FROM
				dbo.TOPersonalTable LEFT OUTER JOIN
				dbo.ReportPositionTable ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID
				AND RP_PSEDO = 'LEAD'
		)

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, 	CL_NUM,
		TO_ID, TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Отсутствует главный бухгалтер в ТО' AS CL_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON TO_ID_CLIENT = CL_ID
	WHERE TO_REPORT = 1
		AND NOT EXISTS
		(
			SELECT *
			FROM
				dbo.TOPersonalTable LEFT OUTER JOIN
				dbo.ReportPositionTable ON RP_ID = TP_ID_RP
			WHERE TP_ID_TO = TO_ID
				AND RP_PSEDO = 'BUH'
		)

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		TO_ID, TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Неверный телефон "' + TP_SURNAME + '" "' + b.TP_PHONE + '"' AS CL_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON TO_ID_CLIENT = CL_ID INNER JOIN
		dbo.TOPersonalTable a ON a.TP_ID_TO = TO_ID INNER JOIN
		(
			SELECT TP_ID, REPLACE(REPLACE(REPLACE(REPLACE(TP_PHONE, '(', ''), ')', ''), '-', ''), ' ', '') AS TP_PHONE
			FROM
				(
					SELECT TP_ID, LTRIM(RTRIM(TP_PHONE)) AS TP_PHONE
					FROM dbo.TOPersonalTable
					WHERE CHARINDEX(',', TP_PHONE) = 0

					UNION ALL

					SELECT TP_ID, LTRIM(RTRIM(Item))
					FROM
						dbo.TOPersonalTable CROSS APPLY
						dbo.GET_STRING_TABLE_FROM_LIST(TP_PHONE, ',')
					WHERE CHARINDEX(',', TP_PHONE) <> 0
				) AS o_O
		) b ON a.TP_ID = b.TP_ID
	WHERE LEN(b.TP_PHONE) <> 11 AND TO_REPORT = 1
		AND EXISTS
			(
				SELECT *
				FROM
					dbo.TODistrTable INNER JOIN
					dbo.DistrTable ON DIS_ID = TD_ID_DISTR INNER JOIN
					dbo.SystemTable ON SYS_ID = DIS_ID_SYSTEM INNER JOIN
					dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
								AND RN_DISTR_NUM = DIS_NUM
								AND RN_COMP_NUM = DIS_COMP_NUM
				WHERE TD_ID_TO = TO_ID AND RN_SERVICE = 0
			)

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		TO_ID, TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Не введен фактический адрес ТО' AS CL_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON CL_ID = TO_ID_CLIENT
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.TOAddressTable
			WHERE TA_ID_TO = TO_ID
		) AND TO_REPORT = 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		TO_ID, TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Недопустимый символ в названии ТО' AS CL_ERROR
	FROM
		dbo.TOTable INNER JOIN
		dbo.ClientTable ON CL_ID = TO_ID_CLIENT
	WHERE (TO_NAME LIKE '%;%'
		OR TO_NAME LIKE '%' + CHAR(10) + '%'
		OR TO_NAME LIKE '%' + CHAR(13) + '%')
		AND TO_REPORT = 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Неоднозначен сервис-инженер клиента. Укажите одну основную ТО' AS CL_ERROR
	FROM dbo.ClientTable
	WHERE
		(
			SELECT COUNT(*)
			FROM dbo.TOTable
			WHERE TO_ID_CLIENT = CL_ID
		) > 1 AND
		(
			SELECT COUNT(DISTINCT TO_ID_COUR)
			FROM dbo.TOTable
			WHERE TO_ID_CLIENT = CL_ID
		) <> 1 AND
		(
			SELECT COUNT(*)
			FROM dbo.TOTable
			WHERE TO_ID_CLIENT = CL_ID
				AND TO_MAIN = 1
		) <> 1

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		TO_ID AS TO_ID, TO_NUM AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Нет обслуживаемых дистрибутивов, но указан сервис-инженер' AS CL_ERROR
	FROM
		dbo.ClientTable INNER JOIN
		dbo.TOTable ON TO_ID_CLIENT = CL_ID INNER JOIN
		dbo.CourierTable ON COUR_ID = TO_ID_COUR LEFT OUTER JOIN
		dbo.SubhostTable ON SH_ID = CL_ID_SUBHOST
	WHERE NOT EXISTS
		(
			SELECT *
			FROM
				dbo.DistrServiceView INNER JOIN
				dbo.TODistrTable ON TD_ID_DISTR = DIS_ID
			WHERE TO_ID = TD_ID_TO
				AND RN_SERVICE = 0
		)  AND NOT EXISTS
		(
			SELECT *
			FROM
				dbo.TODistrView a
				LEFT OUTER JOIN dbo.ClientDistrView e ON e.DIS_ID = a.DIS_ID
			WHERE TD_ID_TO = TO_ID AND DSS_REPORT = 1 AND SYS_ID_SO <> 1
		)
		AND COUR_NAME <> '------------------'
		AND SH_SUBHOST = 0
		AND CL_PSEDO NOT LIKE '%(Н)'
		AND TO_PARENT IS NULL

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		TO_ID AS TO_ID, TO_NUM AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Есть обслуживаемые дистрибутивы, но не указан сервис-инженер' AS CL_ERROR
	FROM
		dbo.ClientTable INNER JOIN
		dbo.TOTable ON TO_ID_CLIENT = CL_ID INNER JOIN
		dbo.CourierTable ON COUR_ID = TO_ID_COUR LEFT OUTER JOIN
		dbo.SubhostTable ON SH_ID = CL_ID_SUBHOST
	WHERE EXISTS
		(
			SELECT *
			FROM
				dbo.DistrServiceView INNER JOIN
				dbo.TODistrTable ON TD_ID_DISTR = DIS_ID
			WHERE TO_ID = TD_ID_TO
				AND RN_SERVICE = 0
		) AND COUR_NAME = '------------------'
		AND SH_SUBHOST = 0

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Неверная длина ИНН' AS CL_ERROR
	FROM dbo.ClientTable
	WHERE LEN(CL_INN) NOT IN (10, 12)
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientDistrView
				WHERE CD_ID_CLIENT = CL_ID
					AND DSS_REPORT = 1
			)

	UNION ALL

	SELECT
		CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
		NULL AS TO_ID, NULL AS TO_NUM,
		NULL AS DIS_ID, NULL AS DIS_STR,
		'Неверная длина КПП (' + ISNULL(CL_KPP, '') + ')' AS CL_ERROR
	FROM dbo.ClientTable
	WHERE LEN(CL_INN) = 10 AND LEN(CL_KPP) <> 9
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientDistrView
				WHERE CD_ID_CLIENT = CL_ID
					AND DSS_REPORT = 1
			)

    UNION ALL

    SELECT
        CL_ID, CL_PSEDO, CL_FULL_NAME, CL_NUM,
        TO_ID, TO_NUM,
        NULL AS DIS_ID, NULL AS DIS_STR,
        'Не совпадает руководитель клиента и основной ТО' AS CL_ERROR
	FROM dbo.TOTable                    AS T
	INNER JOIN dbo.ClientTable          AS CL ON T.TO_ID_CLIENT = CL.CL_ID
	INNER JOIN dbo.TOPersonalTable      AS TP ON TP.TP_ID_TO = T.TO_ID
	INNER JOIN dbo.ReportPositionTable  AS TR ON TR.RP_ID = TP.TP_ID_RP AND TR.RP_PSEDO = 'RES'
	INNER JOIN dbo.ClientPersonalTable  AS CP ON CP.PER_ID_CLIENT = CL.CL_ID
	INNER JOIN dbo.ReportPositionTable  AS CR ON CR.RP_ID = CP.PER_ID_REPORT_POS AND CR.RP_PSEDO = 'RES'
	WHERE T.TO_MAIN = 1
	    AND
	    (
	        TP.TP_SURNAME != CP.PER_FAM
	        OR TP.TP_NAME != CP.PER_NAME
	        OR TP.TP_OTCH != CP.PER_OTCH
	    )GO
