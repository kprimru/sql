USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_PRINT_CONTRACT_SELECT]
	@LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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
			/*
			INNER JOIN dbo.ContractTable z ON z.ClientID = a.CL_ID
			INNER JOIN dbo.ContractTypeTable y ON y.ContractTypeID = z.ContractTypeID
			INNER JOIN dbo.ContractPayTable x ON x.ContractPayID = z.ContractPayID
			*/
			CROSS APPLY
			(
				SELECT
					[ContractNumber] = C.[NUM_S],
					ContractTypeName,
					ContractBegin = DateFrom,
					ContractDate = SignDate,
					ContractEnd = ExpireDate,
					ContractConditions = D.Comments,
					ContractPayName,
					ContractYear = DatePart(Year, Y.START),
					ContractFixed = ContractPrice
				FROM Contract.ClientContracts CC
				INNER JOIN Contract.Contract C ON CC.Contract_Id = C.ID
				INNER JOIN Common.Period Y ON Y.ID = C.ID_YEAR
				CROSS APPLY
				(
					SELECT TOP (1)
						ContractTypeName, ExpireDate, Comments, ContractPayName, ContractPrice
					FROM Contract.ClientContractsDetails D
					INNER JOIN dbo.ContractTypeTable T ON T.ContractTypeID = D.Type_Id
					INNER JOIN dbo.ContractPayTable P ON P.ContractPayID = D.PayType_Id
					WHERE D.[Contract_Id] = CC.[Contract_Id]
					ORDER BY D.[Date] DESC
				) D
				WHERE	CC.Client_Id = a.CL_ID
					AND DateFrom <= GetDate() AND (DateTo >= GetDate() OR DateTo IS NULL)
			) D

		UNION ALL

		SELECT
			CL_ID,
			ContractNumber, ContractTypeName, ContractBegin, ContractDate, ContractEnd,
			ContractConditions, ContractPayName, ContractYear, ContractFixed
		FROM
			@CLIENT a
			CROSS APPLY
			(
				SELECT TOP (1)
					[ContractNumber] = C.[NUM_S],
					ContractTypeName,
					ContractBegin = DateFrom,
					ContractDate = SignDate,
					ContractEnd = ExpireDate,
					ContractConditions = D.Comments,
					ContractPayName,
					ContractYear = DatePart(Year, Y.START),
					ContractFixed = ContractPrice
				FROM Contract.ClientContracts CC
				INNER JOIN Contract.Contract C ON CC.Contract_Id = C.ID
				INNER JOIN Common.Period Y ON Y.ID = C.ID_YEAR
				CROSS APPLY
				(
					SELECT TOP (1)
						ContractTypeName, ExpireDate, Comments, ContractPayName, ContractPrice
					FROM Contract.ClientContractsDetails D
					INNER JOIN dbo.ContractTypeTable T ON T.ContractTypeID = D.Type_Id
					INNER JOIN dbo.ContractPayTable P ON P.ContractPayID = D.PayType_Id
					WHERE D.[Contract_Id] = CC.[Contract_Id]
					ORDER BY D.[Date] DESC
				) D
				WHERE	CC.Client_Id = a.CL_ID
				ORDER BY [DateFrom] DESC
			) D
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Contract.ClientContracts CC
				INNER JOIN Contract.Contract C ON CC.Contract_Id = C.ID
				WHERE	CC.Client_Id = a.CL_ID
					AND DateFrom <= GetDate() AND (DateTo >= GetDate() OR DateTo IS NULL)
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
				FROM Contract.ClientContracts CC
				INNER JOIN Contract.Contract C ON CC.Contract_Id = C.ID
				WHERE	CC.Client_Id = a.CL_ID
			)

		ORDER BY CL_ID, ContractBegin

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_PRINT_CONTRACT_SELECT] TO rl_client_p;
GO