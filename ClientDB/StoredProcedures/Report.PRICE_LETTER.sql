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
		ServiceName AS [��],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('���', '����')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|���-����],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('1/�')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|1/�],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('�/�')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|�/�],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('����')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|����],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('���')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|���],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('����')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|����],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('���')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|���],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('���1')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|���1],
		(
			SELECT COUNT(DISTINCT ClientID)
			FROM 
				dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c ON b.ID_CLIENT = c.CLientID
			WHERE a.ServiceID = c.ServiceID
				AND b.DS_REG = 0
				AND c.ServiceStatusID = 2
				AND DistrTypeName IN ('���2')
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFDistrFinancingView z
						WHERE b.SystemBaseName = z.SYS_REG_NAME
							AND b.DISTR = z.DIS_NUM
							AND b.COMP = z.DIS_COMP_NUM
							AND DF_FIXED_PRICE <> 0
					)
		) AS [���������� �������� ��� ������������� ���������|���2]
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
