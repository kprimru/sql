USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_ARCHIVE]
	@ID				UNIQUEIDENTIFIER,
	@POTENTIAL		UNIQUEIDENTIFIER,
	@NEXT_MON		UNIQUEIDENTIFIER,
	@AVAILABILITY	UNIQUEIDENTIFIER,
	@CHARACTER		UNIQUEIDENTIFIER = NULL,
	@PAY_CAT		UNIQUEIDENTIFIER = NULL
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
		INSERT INTO Client.CompanyArchive(ID_COMPANY, ID_POTENTIAL, ID_NEXT_MON, ID_AVAILABILITY, ID_CHARACTER, ID_PAY_CAT)
			SELECT @ID, @POTENTIAL, @NEXT_MON, @AVAILABILITY, @CHARACTER, @PAY_CAT
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyArchive
					WHERE ID_COMPANY = @ID
						AND STATUS = 1
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_ARCHIVE] TO rl_archive_return;
GO
