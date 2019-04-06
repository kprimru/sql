USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CONTRACT_PAY_CONDITION]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		SELECT 
			ServiceName AS [СИ], 
			ClientFullName AS [Клиент], DistrStr AS [Дистрибутив],
			ContractPayName AS [Условие оплаты],--ContractPayDay AS [], ContractPayMonth AS [],
			COP_NAME AS [Условие оплаты в DBF]--, COP_MONTH AS [], COP_DAY AS []
		FROM
			(
				SELECT 
					ClientID, ClientFullName, ServiceName, PayTypeName, ContractPayName, ContractPayDay, ContractPayMonth,
					SystemBaseName, DISTR, COMP, DistrStr
				FROM
					dbo.ClientTable a
					INNER JOIN dbo.ServiceTable ON ClientServiceID = ServiceID
					INNER JOIN dbo.PayTypeTable b ON a.PayTypeID = b.PayTypeID
					OUTER APPLY
						(
							SELECT TOP 1 ContractPayName, ContractPayDay, ContractPayMonth
							FROM 
								dbo.ContractTable z
								INNER JOIN dbo.ContractPayTable y ON z.ContractPayID = y.ContractPayID
							WHERE z.ClientID = a.ClientID
							ORDER BY ContractEnd DESC
						) AS o_O
					CROSS APPLY
						(
							SELECT TOP 1 SystemBaseName, DISTR, COMP, DIstrStr
							FROM dbo.ClientDistrView WITH(NOEXPAND)							
							WHERE ClientID = ID_CLIENT
							ORDER BY SystemOrder, DISTR, COMP
						) AS y
				WHERE StatusID = 2 AND STATUS = 1 --AND ID_HEAD IS NULL
			) AS CLIENT
			LEFT OUTER JOIN
			(
				SELECT CL_PSEDO, COP_NAME, COP_MONTH, COP_DAY, SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM
				FROM 
					[PC275-SQL\DELTA].DBF.dbo.ClientTable a
					INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ClientDistrTable b ON a.CL_ID = CD_ID_CLIENT 
					INNER JOIN [PC275-SQL\DELTA].DBF.dbo.DistrView c ON b.CD_ID_DISTR = c.DIS_ID
					INNER JOIN [PC275-SQL\DELTA].DBF.dbo.DistrServiceStatusTable d ON d.DSS_ID = b.CD_ID_SERVICE AND DSS_REPORT = 1
					CROSS APPLY
					(
						SELECT TOP 1 COP_NAME, COP_DAY, COP_MONTH
						FROM
							[PC275-SQL\DELTA].DBF.dbo.ContractDistrTable e
							INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ContractTable f ON f.CO_ID = e.COD_ID_CONTRACT 
							INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ContractPayTable g ON g.COP_ID = CO_ID_PAY
						WHERE COD_ID_DISTR = DIS_ID AND CO_ACTIVE = 1 AND CO_ID_CLIENT = CL_ID
					) AS u
			) AS DBF ON SYS_REG_NAME = SystemBaseName AND DISTR = DIS_NUM AND COMP = DIS_COMP_NUM
	WHERE ContractPayDay <> COP_DAY OR ContractPayMonth <> COP_MONTH
	ORDER BY ServiceName, ClientFullname
END
