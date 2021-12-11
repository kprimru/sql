USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[FORM_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[FORM_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[FORM_SELECT]
	@FILTER NVARCHAR(128) = NULL
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

		SELECT ID, NUM, NAME, FILE_PATH
		FROM Contract.Forms
		WHERE @FILTER IS NULL
			OR NAME LIKE @FILTER
			OR NUM LIKE @FILTER
		ORDER BY NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[FORM_SELECT] TO rl_contract_form_r;
GO
