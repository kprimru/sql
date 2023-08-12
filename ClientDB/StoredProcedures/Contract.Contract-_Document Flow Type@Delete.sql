USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Contract->Document Flow Type@Delete]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[Contract->Document Flow Type@Delete]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Contract].[Contract->Document Flow Type@Delete]
	@Id		TinyInt
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

		DELETE
		FROM [Contract].[Contracts->Documents Flow Types]
		WHERE [Id] = @Id;


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[Contract->Document Flow Type@Delete] TO rl_contract_document_flow_type_d;
GO
