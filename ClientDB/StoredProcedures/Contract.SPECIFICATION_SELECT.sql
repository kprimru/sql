USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[SPECIFICATION_SELECT]
	@FILTER	NVARCHAR(256) = NULL
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

		SELECT ID, NUM, NAME, NOTE, FILE_PATH
		FROM Contract.Specification
		WHERE @FILTER IS NULL
			OR NUM LIKE @FILTER
			OR NAME LIKE @FILTER
			OR NOTE LIKE @FILTER
		ORDER BY NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Contract].[SPECIFICATION_SELECT] TO rl_contract_specification_r;
GO