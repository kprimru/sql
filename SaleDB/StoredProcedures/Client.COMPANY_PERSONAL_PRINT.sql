USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_PRINT]
	@ID		UNIQUEIDENTIFIER
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
		SELECT
			FIO, b.NAME AS POS_NAME, a.NOTE AS PER_NOTE, d.NAME AS PT_NAME, PHONE, c.NOTE AS PH_NOTE, a.EMAIL
		FROM
			Client.CompanyPersonal a
			LEFT OUTER JOIN Client.Position b ON a.ID_POSITION = b.ID
			LEFT OUTER JOIN Client.CompanyPersonalPhone c ON c.ID_PERSONAL = a.ID
			LEFT OUTER JOIN Client.PhoneType d ON d.ID = c.ID_TYPE
		WHERE a.ID_COMPANY = @ID
		ORDER BY a.FIO, d.NAME, c.PHONE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_PRINT] TO rl_company_p;
GO
