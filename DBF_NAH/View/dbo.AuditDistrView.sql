USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AuditDistrView]
AS
	SELECT
		DIS_ID, DIS_STR,
		NULL AS TO_ID, NULL AS CL_ID,
		'Дистрибутив не распределен клиенту' AS DIS_ER
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
		DIS_ID, DIS_STR,
		NULL AS TO_ID, CD_ID_CLIENT AS CL_ID,
		'Дистрибутив не распределен в ТО' AS DIS_ER
	FROM dbo.DistrView a WITH(NOEXPAND) INNER JOIN
		dbo.ClientDistrTable ON DIS_ID = CD_ID_DISTR
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
		DIS_ID, DIS_STR,
		TO_ID, CL_ID,
		('Дистрибутив клиента "' + CL_PSEDO + '" разнесен в ТО "' + TO_NAME + '" (' + CONVERT(VARCHAR(20), TO_NUM) + ') не принадлежащую данному клиенту') AS DIS_ER
	FROM
		dbo.DistrView WITH(NOEXPAND) INNER JOIN
		dbo.TODistrTable ON TD_ID_DISTR = DIS_ID INNER JOIN
		dbo.ClientDistrTable ON CD_ID_DISTR = DIS_ID INNER JOIN
		dbo.ClientTable ON CL_ID = CD_ID_CLIENT INNER JOIN
		dbo.TOTable ON TO_ID = TD_ID_TO
	WHERE TO_ID_CLIENT <> CL_ID

	UNION ALL

	SELECT
		DIS_ID, DIS_STR,
		NULL AS TO_ID, CL_ID, 'Признак подхоста на рег.узле и в базе не совпадают' AS DIS_ER
	FROM
		dbo.ClientDistrView			a
		INNER JOIN dbo.ClientTable	b	on	a.cd_id_client=b.cl_id
		INNER JOIN dbo.SubhostTable	c	on	b.cl_id_subhost=c.sh_id
		INNER JOIN dbo.SystemTable	d	on	a.sys_id=d.sys_id
		INNER JOIN dbo.RegnodeTable	e	on	a.dis_num=e.rn_distr_num
									and d.sys_reg_name=e.rn_sys_name
									and a.dis_comp_num=e.rn_comp_num
		WHERE rn_subhost != sh_subhost

	UNION ALL
	SELECT
		DIS_ID, DIS_STR, NULL AS TO_ID, CL_ID,
		'Названия подхостов на рег.узле и в базе не совпадают' AS DIS_ER
	FROM
		dbo.ClientDistrView			a
		INNER JOIN dbo.ClientTable	b	on	a.cd_id_client=b.cl_id
		INNER JOIN dbo.SubhostTable	c	on	b.cl_id_subhost=c.sh_id
		INNER JOIN dbo.SystemTable	d	on	a.sys_id=d.sys_id
		INNER JOIN dbo.RegnodeTable	e	on	a.dis_num=e.rn_distr_num
									and d.sys_reg_name=e.rn_sys_name
									and a.dis_comp_num=e.rn_comp_num
	-- 3.6.09 Денисов А.С. Переправлен щаблон подхоста на РЦ. Вернул на место. Затупил :-)
	WHERE rn_comment NOT LIKE '%' + sh_lst_name + '%'
	--WHERE rn_comment NOT LIKE  '(' + sh_lst_name + ')%'

	UNION ALL

	SELECT
		DIS_ID, DIS_STR,
		TD_ID_TO AS TO_ID, CL_ID,
		'Дистрибутив не указан ни в одном действующем договоре' AS DIS_ER
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
				WHERE CO_ID_CLIENT = CL_ID AND CO_ACTIVE = 1
			)
GO
