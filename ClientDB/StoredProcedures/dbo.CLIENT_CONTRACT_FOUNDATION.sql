USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_FOUNDATION]
	@ID		INT,
	@ID_FOUND	UNIQUEIDENTIFIER,
	@FOUND_END	SMALLDATETIME,
	@NOTE		NVARCHAR(MAX)
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

		INSERT INTO dbo.FoundationLog(ID_CONTRACT)
			VALUES(@ID)

		UPDATE dbo.ContractTable
		SET	ID_FOUNDATION = @ID_FOUND,
			FOUND_END = @FOUND_END,
			FOUND_NOTE = @NOTE
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
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_FOUNDATION] TO rl_client_contract_foundation;
GO
