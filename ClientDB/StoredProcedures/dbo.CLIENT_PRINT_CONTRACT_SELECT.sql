USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_PRINT_CONTRACT_SELECT]
	@LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CLIENT	TABLE(CL_ID INT PRIMARY KEY)

	INSERT INTO @CLIENT
		SELECT ID
		FROM dbo.TableIDFromXML(@LIST)

	SELECT 
		CL_ID, 
		ContractNumber, ContractTypeName, ContractBegin, ContractDate, ContractEnd,
		ContractConditions, ContractPayName, ContractYear, ContractFixed
	FROM 
		@CLIENT a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.CL_ID = b.ClientID
		INNER JOIN dbo.ContractTable z ON z.ClientID = a.CL_ID
		INNER JOIN dbo.ContractTypeTable y ON y.ContractTypeID = z.ContractTypeID
		INNER JOIN dbo.ContractPayTable x ON x.ContractPayID = z.ContractPayID			
	WHERE ContractBegin <= GETDATE() AND ContractEnd >= GETDATE()
		AND EXISTS
		(
			SELECT *
			FROM dbo.ContractTable			
			WHERE ClientID = CL_ID
				AND ContractBegin <= GETDATE() AND ContractEnd >= GETDATE()
		)
		
	UNION ALL
	
	SELECT 
		CL_ID, 
		ContractNumber, ContractTypeName, ContractBegin, ContractDate, ContractEnd,
		ContractConditions, ContractPayName, ContractYear, ContractFixed
	FROM 
		@CLIENT a
		INNER JOIN 
			(
				SELECT 
					ClientID, ContractNumber, ContractTypeName, ContractBegin, ContractDate, ContractEnd,
					ContractConditions, ContractPayName, ContractYear, ContractFixed,
					ROW_NUMBER() OVER(PARTITION BY CLientID ORDER BY ContractBegin DESC) AS RN
				FROM 
					dbo.ContractTable z
					INNER JOIN dbo.ContractTypeTable y ON y.ContractTypeID = z.ContractTypeID
					INNER JOIN dbo.ContractPayTable x ON x.ContractPayID = z.ContractPayID
			) AS t ON t.ClientID = a.CL_ID AND RN = 1
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ContractTable			
			WHERE ClientID = CL_ID
				AND ContractBegin <= GETDATE() AND ContractEnd >= GETDATE()
		)
		
	ORDER BY CL_ID, ContractBegin
END
