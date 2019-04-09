USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CLIENT_FINANCING_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientFullName AS '������', ContractTypeName AS '��� �������', 
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM 
						dbo.ClientDistrView z
						INNER JOIN dbo.DBFDistrFinancingView y ON z.SystemBaseName = y.SYS_REG_NAME AND z.DISTR = y.DIS_NUM AND z.COMP = y.DIS_COMP_NUM
					WHERE z.ID_CLIENT = ClientID AND z.DS_REG = 0 AND DF_FIXED_PRICE <> 0
				) THEN '����.�����'
			WHEN EXISTS
				(
					SELECT *
					FROM 
						dbo.ClientDistrView z
						INNER JOIN dbo.DBFDistrFinancingView y ON z.SystemBaseName = y.SYS_REG_NAME AND z.DISTR = y.DIS_NUM AND z.COMP = y.DIS_COMP_NUM
					WHERE z.ID_CLIENT = ClientID AND z.DS_REG = 0 AND DF_DISCOUNT <> 0
				) THEN '������'
			ELSE '�����������'
		END AS '�������'
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ContractTypeTable b ON a.ClientContractTypeID = b.ContractTypeID	
	WHERE a.STATUS = 1 AND a.StatusID = 2
	ORDER BY ClientFullName
END
