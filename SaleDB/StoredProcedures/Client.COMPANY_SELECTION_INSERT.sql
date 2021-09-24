USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_SELECTION_INSERT]
	@ID		NVARCHAR(MAX),
	@RC		INT = NULL OUTPUT
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
		INSERT INTO Client.CompanySelection(ID_COMPANY)
			SELECT ID
			FROM Common.TableGUIDFromXML(@ID) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanySelection b
					WHERE a.ID = b.ID
						AND USR_NAME = ORIGINAL_LOGIN()
				)

		SELECT @RC = COUNT(*)
		FROM Client.CompanySelection
		WHERE USR_NAME  = ORIGINAL_LOGIN()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_SELECTION_INSERT] TO public;
GO
