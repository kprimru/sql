USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[Contract->Document Flow Type@Insert]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[Contract->Document Flow Type@Insert]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Contract].[Contract->Document Flow Type@Insert]
	@Id		TinyInt,
	@Code	VarChar(50),
	@Name	VarChar(100)
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

		INSERT INTO [Contract].[Contracts->Documents Flow Types]([Code], [Name])
		VALUES(@Code, @Name);

		SELECT @Id = Scope_Identity();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[Contract->Document Flow Type@Insert] TO rl_contract_document_flow_type_i;
GO
