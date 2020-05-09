USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_DOCUMENT_SAVE]
	@Contract_Id	UniqueIdentifier,
	@RowIndex		SmallInt,
	@Date			SmallDateTime,
	@Type_Id		UniqueIdentifier,
	@Note			NVarChar(MAX)
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

		IF @RowIndex IS NULL
			INSERT INTO Contract.ClientContractsDocuments(Contract_Id, RowIndex, Type_Id, Date, Note)
			SELECT
				@Contract_Id,
				IsNull((SELECT Max(RowIndex) + 1 FROM Contract.ClientContractsDocuments WHERE Contract_Id = @Contract_Id), 1),
				@Type_Id, @Date, @Note
		ELSE
			UPDATE Contract.ClientContractsDocuments
			SET	Type_Id		=	@Type_Id,
				Date		=	@Date,
				Note		=	@Note
			WHERE Contract_Id = @Contract_Id
				AND RowIndex = @RowIndex;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_DOCUMENT_SAVE] TO rl_contract_document;
GO