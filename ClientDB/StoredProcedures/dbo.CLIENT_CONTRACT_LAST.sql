USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_LAST]
	@ID	INT
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

		SELECT
			ContractBegin, ContractEnd, ContractYear, ContractNumber, ContractTypeName, ContractConditions,
			c.NAME, a.FOUND_END
		FROM
			dbo.ContractTable a
			INNER JOIN dbo.ContractTypeTable b ON a.ContractTypeID = b.ContractTypeID
			LEFT OUTER JOIN dbo.ContractFoundation c ON c.ID = a.ID_FOUNDATION
		WHERE ContractID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_LAST] TO rl_client_contract_r;
GO
