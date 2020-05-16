USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_PHONE_SELECT]
	@ID			UNIQUEIDENTIFIER,
	@DEL		BIT
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
		SELECT a.ID, ID_PERSONAL, ID_TYPE, NAME, PHONE, PHONE_S, NOTE, STATUS
		FROM
			Client.CompanyPersonalPhone a
			LEFT OUTER JOIN Client.PhoneType b ON a.ID_TYPE = b.ID
		WHERE a.ID_PERSONAL = @ID
			AND(STATUS=1 OR STATUS=3 AND @DEL=1)
		ORDER BY NAME, PHONE_S

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_PHONE_SELECT] TO rl_company_personal_r;
GO