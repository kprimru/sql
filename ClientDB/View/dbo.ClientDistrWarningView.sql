USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientDistrWarningView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientDistrWarningView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientDistrWarningView]
AS
	-- ToDo - избавиться от этого. План отвратительный
	SELECT ClientID, REG_ERROR
	FROM
		(
			SELECT ID_CLIENT AS ClientID,
				CASE
					WHEN ISNULL(ISNULL(b.SubhostName, c.SubhostName), Cast([System].[Setting@Get]('SUBHOST_NAME') AS VarChar(128))) <> Cast([System].[Setting@Get]('SUBHOST_NAME') AS VarChar(128)) THEN 'Дистрибутив установлен у другого подхоста'
					WHEN a.SystemReg = 0 THEN ''
					WHEN b.ID IS NULL THEN
						CASE
							WHEN c.ID IS NULL THEN 'Система не найдена в РЦ'
							ELSE 'Система заменена (' + c.SystemShortName + ')'
						END
					WHEN a.DistrTypeID <> b.DistrTypeID THEN 'Не совпадает тип сети. В РЦ - ' + b.DistrTypeName
					WHEN a.DS_ID <> b.DS_ID THEN 'Не совпадает статус системы. В РЦ - ' + b.DS_NAME
					-- Внимание! Расчет на NULL-значение SST_ID_MASTER
					-- WHEN e.SST_ID_MASTER != a.SystemTypeID THEN 'Не совпадает тип системы. В РЦ - ' + b.SST_SHORT
					WHEN
						ISNULL((
							SELECT ID_CLIENT
							FROM
								dbo.ClientDistrView z WITH(NOEXPAND)
								INNER JOIN dbo.RegNodeMainDistrView y WITH(NOEXPAND) ON z.HostID = y.MainHostID AND z.DISTR = y.MainDistrNumber AND z.COMP = y.MainCompNumber
							WHERE y.SystemBaseName = a.SystemBaseName AND y.DistrNumber = a.DISTR AND y.CompNumber = a.COMP
						), a.ID_CLIENT) <> a.ID_CLIENT THEN 'Система зарегистрирована в комплекте клиента ' + (
							SELECT ClientFullName + ' (' + y.Complect + ')'
							FROM
								dbo.ClientDistrView z WITH(NOEXPAND)
								INNER JOIN dbo.RegNodeMainDistrView y WITH(NOEXPAND) ON z.HostID = y.MainHostID AND z.DISTR = y.MainDistrNumber AND z.COMP = y.MainCompNumber
								INNER JOIN dbo.ClientTable x ON x.ClientID = z.ID_CLIENT
							WHERE y.SystemBaseName = a.SystemBaseName AND y.DistrNumber = a.DISTR AND y.CompNumber = a.COMP
						)
					ELSE ''
				END AS REG_ERROR
			FROM
				dbo.ClientDistrView a WITH(NOEXPAND)
				LEFT OUTER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
								AND b.DistrNumber = a.DISTR
								AND b.CompNumber = a.COMP
				LEFT OUTER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = a.HostID
								AND c.DistrNumber = a.DISTR
								AND c.CompNumber = a.COMP
				LEFT JOIN Din.SystemType AS e ON b.SST_ID = e.SST_ID


			UNION ALL

			SELECT ID_CLIENT AS ClientID, 'Дистрибутив установлен в комплекте с системами клиента'
			FROM
				dbo.ClientDistrView a WITH(NOEXPAND)
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
								AND b.DistrNumber = a.DISTR
								AND b.CompNumber = a.COMP
				INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.Complect = b.Complect
			WHERE  c.DS_REG = 0 AND c.DistrType NOT IN ('NEK')
				AND c.SubhostName = Cast([System].[Setting@Get]('SUBHOST_NAME') AS VarChar(128))
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE /*z.ClientID = @CLIENTID
							AND */z.HostID = c.HostID
							AND z.DISTR = c.DistrNumber
							AND z.COMP = c.CompNumber
					)
		) AS o_O
	WHERE REG_ERROR <> ''
GO
