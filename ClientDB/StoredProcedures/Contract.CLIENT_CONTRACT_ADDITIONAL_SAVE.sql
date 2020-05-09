USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_ADDITIONAL_SAVE]
	@Id			UniqueIdentifier,
	@Num		Int,
	@SignDate	SmallDateTime,
	@DateFrom	SmallDateTime,
	@DateTo		SmallDateTime,
	@Comment	NVarChar(Max)
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

		UPDATE Contract.Additional SET
			NUM			= @Num,
			SignDate	= @SignDate,
			DateFrom	= @DateFrom,
			DateTo		= @DateTo,
			Comment		= @Comment
		WHERE ID = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_ADDITIONAL_SAVE] TO rl_client_contract_u;
GO