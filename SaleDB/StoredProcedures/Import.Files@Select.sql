USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Import].[Files@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Import].[Files@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [Import].[Files@Select]
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY

		SELECT F.[Id], F.[UploadDateTime], F.[UploadUser]
		FROM [Import].[File] AS F
		ORDER BY F.[UploadDateTime] DESC;

	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Import].[Files@Select] TO rl_company_import;
GO
