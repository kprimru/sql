USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_ARCHIVE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_ARCHIVE_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_ARCHIVE_GET]
	@ID				UNIQUEIDENTIFIER
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
		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Client.CompanyArchive
		WHERE ID = @ID

		DECLARE @TMP TABLE(DATA NVARCHAR(MAX))

		INSERT INTO @TMP(DATA)
			EXEC  Client.CHANGE_SALE_SELECT @COMPANY

		SELECT
			a.ID_POTENTIAL AS NEW_POTENTIAL, a.ID_NEXT_MON AS NEW_NEXT_MON,
			a.ID_AVAILABILITY AS NEW_AVAILABILITY, a.ID_CHARACTER AS NEW_CHARACTER,
			a.ID_PAY_CAT AS NEW_PAY_CAT,
			b.ID_POTENTIAL AS OLD_POTENTIAL, b.ID_NEXT_MON AS OLD_NEXT_MON,
			b.ID_AVAILABILITY AS OLD_AVAILABILITY, b.ID_CHARACTER AS OLD_CHARACTER,
			b.ID_PAY_CAT AS OLD_PAY_CAT,
			(SELECT DATA + CHAR(10) + CHAR(10) FROM @TMP FOR XML PATH('')) AS CHANGE
		FROM
			Client.CompanyArchive a CROSS JOIN
			Client.Company b
		WHERE a.ID = @ID
			AND b.ID = @COMPANY

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_ARCHIVE_GET] TO rl_archive_apply;
GO
