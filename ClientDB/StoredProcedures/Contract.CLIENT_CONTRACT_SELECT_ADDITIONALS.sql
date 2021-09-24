USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_ADDITIONALS]
	@Contract_Id	UniqueIdentifier,
	@HideUnsigned	Bit					= 0
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
		    CA.ID, CA.NUM, CA.REG_DATE, CA.NOTE, CA.Comment, CA.DateFrom, CA.DateTo, CA.SignDate,
		    [IsActive] = Cast(CASE WHEN CA.SignDate IS NOT NULL AND CA.DateTo IS NULL THEN 1 ELSE 0 END AS Bit)
		FROM Contract.Additional AS CA
		WHERE ID_CONTRACT = @Contract_Id
			AND (@HideUnsigned = 0 OR @HideUnsigned = 1 AND CA.SignDate IS NOT NULL)
		ORDER BY CA.NUM DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CLIENT_CONTRACT_SELECT_ADDITIONALS] TO rl_client_contract_r;
GO
