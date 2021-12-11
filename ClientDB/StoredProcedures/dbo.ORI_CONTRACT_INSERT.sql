USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ORI_CONTRACT_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ORI_CONTRACT_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ORI_CONTRACT_INSERT]
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@SYSTEM	VARCHAR(MAX),
	@NOTE	VARCHAR(MAX),
	@ID	INT = NULL OUTPUT
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

		INSERT INTO dbo.OriContractTable(ClientID, OriContractDate, OriContractSystem, OriContractNote)
			VALUES(@CLIENT, @DATE, @SYSTEM, @NOTE)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ORI_CONTRACT_INSERT] TO rl_ori_contract_i;
GO
