USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Contracts->Documents Flow Types@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[Contracts->Documents Flow Types@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[Contracts->Documents Flow Types@Select]
	@Filter		VarChar(500) = NULL
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

		SELECT [Id], [Name], [Code]
		FROM [Contract].[Contracts->Documents Flow Types]
		ORDER BY [Name];


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[Contracts->Documents Flow Types@Select] TO rl_contract_document_flow_type_r;
GO
