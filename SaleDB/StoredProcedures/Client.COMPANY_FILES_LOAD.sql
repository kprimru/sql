USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_FILES_LOAD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_FILES_LOAD]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_FILES_LOAD]
	@ID	UNIQUEIDENTIFIER
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

	SELECT FILE_NAME, FILE_DATA
	FROM Client.CompanyFiles
	WHERE ID = @ID
END

GO
GRANT EXECUTE ON [Client].[COMPANY_FILES_LOAD] TO rl_company_files_r;
GO
