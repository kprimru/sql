USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_ARCHIVE_WARNING]
	@RC	INT = NULL OUTPUT
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
		DECLARE @CURDATE SMALLDATETIME

		SELECT b.ID, b.NAME, b.NUMBER
		FROM
			Client.CompanyArchiveView a WITH(NOEXPAND)
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			INNER JOIN Client.CompanyWriteList() d ON d.ID = b.ID
		WHERE b.STATUS = 1 
		ORDER BY b.NAME

		SELECT @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Client].[COMPANY_ARCHIVE_WARNING] TO rl_warning_archive;
GO