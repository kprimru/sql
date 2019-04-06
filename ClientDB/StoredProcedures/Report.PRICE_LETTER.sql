USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[PRICE_LETTER]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ServiceName AS [СИ],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('лок', 'Флэш')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|Лок-Флэш],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('1/С')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|1/с],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('м/с')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|м/с],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('СЕТЬ')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|Сеть],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('ОВП')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|ОВП],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('ОВПИ')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|ОВПИ],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('ОВК')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|ОВК],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('ОВМ1')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|ОВМ1],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('ОВМ2')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [Количество клиентов без фиксированной стоимости|ОВМ2]
	FROM dbo.ServiceTable a
	WHERE EXISTS
		(
			SELECT *
			FROM dbo.ClientTable
			WHERE ServiceID = ClientServiceID
				AND STATUS = 1
				AND StatusID = 2
		)
	ORDER BY ServiceName
END
