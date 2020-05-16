USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_WARNING_WARNING]
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
		DECLARE @CUR SMALLDATETIME

		SET @CUR = Common.DateOf(GETDATE())

		SELECT a.ID, b.ID AS ID_COMPANY, b.NAME, a.DATE, a.NOTE
		FROM
			Client.CompanyWarning a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
		WHERE a.STATUS = 1
			AND NOTIFY_USER = ORIGINAL_LOGIN()
			AND DATE <= @CUR
			AND END_DATE IS NULL
		ORDER BY a.DATE DESC, b.NAME


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
GRANT EXECUTE ON [Client].[COMPANY_WARNING_WARNING] TO public;
GO