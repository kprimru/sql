USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_PERSONAL_PHONE_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_PERSONAL_PHONE_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_PHONE_INSERT]
	@PERSONAL	UNIQUEIDENTIFIER,
	@TYPE		UNIQUEIDENTIFIER,
	@PHONE		NVARCHAR(128),
	@PHONE_S	NVARCHAR(64),
	@NOTE		NVARCHAR(MAX)
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
		INSERT INTO Client.CompanyPersonalPhone(ID_PERSONAL, ID_TYPE, PHONE, PHONE_S, NOTE, STATUS, UPD_DATE, UPD_USER)
			VALUES(@PERSONAL, @TYPE, @PHONE, @PHONE_S, @NOTE, 1, GETDATE(), ORIGINAL_LOGIN())

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_PHONE_INSERT] TO rl_company_personal_w;
GO
