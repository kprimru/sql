USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_SYSTEM_SELECT]
	@CLIENTID	INT,
	@SERVICE	BIT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	IF @SERVICE IS NULL
		SET @SERVICE = 0

	SELECT 
		TP, ID, SystemOrder, DistrStr, SystemTypeName, DistrTypeName, 
		DS_NAME, DS_REG, DS_INDEX,
		SystemBegin, SystemEnd, REG_ERROR, ERROR_TYPE,
		CASE
			WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN 'Фикс.сумма: ' + CONVERT(VARCHAR(20), CONVERT(DECIMAL(10, 2), DF_FIXED_PRICE))
			WHEN ISNULL(DF_DISCOUNT, 0) <> 0 THEN 'Скидка: ' + CONVERT(VARCHAR(20), CONVERT(INT, DF_DISCOUNT)) + ' %'
			ELSE ''
		END AS DBF_STR
	FROM
		(
			SELECT 
				'CLIENT' AS TP, a.ID, a.SystemOrder, a.DistrStr,					
				SystemTypeName,	a.DistrTypeName, a.DS_NAME, 
				a.DS_REG, a.DS_INDEX,
				(
					SELECT TOP 1 SystemBegin 
					FROM dbo.ClientSystemDatesTable
					WHERE IDMaster = a.ID
					ORDER BY SystemDate DESC
				) AS SystemBegin,
				(
					SELECT TOP 1 SystemEnd 
					FROM dbo.ClientSystemDatesTable
					WHERE IDMaster = a.ID
					ORDER BY SystemDate DESC
				) AS SystemEnd,
				CASE 
					WHEN b.ID IS NULL THEN	
						CASE 
							WHEN c.ID IS NULL THEN 'Система не найдена в РЦ'
							ELSE 'Система заменена (' + c.SystemShortName + ')'
						END
					WHEN a.DistrTypeID <> b.DistrTypeID THEN 'Не совпадает тип сети. В РЦ - ' + b.DistrTypeName
					WHEN a.DS_ID <> b.DS_ID THEN 'Не совпадает статус системы. В РЦ - ' + b.DS_NAME
					WHEN 
						ISNULL((
							SELECT ClientID
							FROM 
								dbo.ClientSystemView z
								INNER JOIN dbo.RegNodeMainSystemView y WITH(NOEXPAND) ON z.HostID = y.MainHostID AND z.SystemDistrNumber = y.MainDistrNumber AND z.CompNumber = y.MainCompNumber
							WHERE y.SystemBaseName = a.SystemBaseName AND y.DistrNumber = a.SystemDistrNumber AND y.CompNumber = a.CompNumber
						), a.ClientID) <> a.ClientID THEN 'Система зарегистрирована в комплекте клиента ' + (
							SELECT ClientFullName + ' (' + y.Complect + ')'
							FROM 
								dbo.ClientSystemView z
								INNER JOIN dbo.RegNodeMainSystemView y WITH(NOEXPAND) ON z.HostID = y.MainHostID AND z.SystemDistrNumber = y.MainDistrNumber AND z.CompNumber = y.MainCompNumber
								INNER JOIN dbo.ClientTable x ON x.ClientID = z.ClientID
							WHERE y.SystemBaseName = a.SystemBaseName AND y.DistrNumber = a.SystemDistrNumber AND y.CompNumber = a.CompNumber
						)
					ELSE '' 
				END AS REG_ERROR,				
				1 AS ERROR_TYPE,
				SystemBaseName, SystemDistrNumber, a.CompNumber
			FROM
				dbo.ClientSystemView a WITH(NOEXPAND) 
				LEFT OUTER JOIN dbo.RegNodeCurrentView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
								AND b.DistrNumber = a.SystemDistrNumber
								AND b.CompNumber = a.CompNumber
				LEFT OUTER JOIN dbo.RegNodeCurrentView c WITH(NOEXPAND) ON c.HostID = a.HostID
								AND c.DistrNumber = a.SystemDistrNumber
								AND c.CompNumber = a.CompNumber
			WHERE  ClientID = @CLIENTID
				
			
			UNION ALL

			SELECT 
				DISTINCT 'REG' AS TP, c.ID, c.SystemOrder, c.DistrStr,					
				'',	c.DistrTypeName, c.DS_NAME, 
				c.DS_REG, c.DS_INDEX,
				c.RegisterDate,
				NULL,
				'Дистрибутив установлен в комплекте с системами клиента',
				2 AS ERROR_TYPE,
				NULL AS SystemBaseName, NULL AS SystemDistrNumber, NULL AS CompNumber
			FROM
				dbo.ClientSystemView a WITH(NOEXPAND) 
				INNER JOIN dbo.RegNodeCurrentView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
								AND b.DistrNumber = a.SystemDistrNumber
								AND b.CompNumber = a.CompNumber
				INNER JOIN dbo.RegNodeCurrentView c WITH(NOEXPAND) ON c.Complect = b.Complect						
			WHERE  ClientID = @CLIENTID AND c.DS_REG = 0
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientSystemView z WITH(NOEXPAND) 
						WHERE /*z.ClientID = @CLIENTID
							AND */z.SystemID = c.SystemID
							AND z.SystemDistrNumber = c.DistrNumber
							AND z.CompNumber = c.CompNumber
					)
		) AS o_O
		LEFT OUTER JOIN [PC264-SQL\DELTA].DBF.dbo.SystemTable ON SYS_REG_NAME = SystemBaseName
		LEFT OUTER JOIN [PC264-SQL\DELTA].DBF.dbo.DistrTable ON DIS_ID_SYSTEM = SYS_ID AND DIS_NUM = SystemDistrNumber AND DIS_COMP_NUM = CompNumber
		LEFT OUTER JOIN [PC264-SQL\DELTA].DBF.dbo.DistrFinancingTable ON DIS_ID = DF_ID_DISTR
	WHERE (DS_REG = 0) 
			OR  (@SERVICE = 0 AND DS_REG IN (1, 2)) 
			OR REG_ERROR <> ''
	ORDER BY DS_REG, SystemOrder, DistrStr
END