USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[TYPE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[TYPE_SELECT]
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

		SELECT ID, NAME, CDAY, CMONTH, PREFIX, FORM
		FROM Contract.Type
		WHERE @FILTER IS NULL
			OR NAME LIKE @FILTER
		ORDER BY NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[TYPE_SELECT] TO rl_contract_type_r;
GO
