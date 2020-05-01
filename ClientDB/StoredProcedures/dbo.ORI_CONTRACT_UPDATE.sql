USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ORI_CONTRACT_UPDATE]
	@ID	INT,
	@CLIENT	INT,
	@DATE	SMALLDATETIME,
	@SYSTEM	VARCHAR(MAX),
	@NOTE	VARCHAR(MAX)
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

		UPDATE dbo.OriContractTable
		SET OriContractDate = @DATE,
			OriContractSystem = @SYSTEM,
			OriContractNote = @NOTE
		WHERE OriContractID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ORI_CONTRACT_UPDATE] TO rl_ori_contract_u;
GO