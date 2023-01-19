USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_PERSONAL_PHONE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_PERSONAL_PHONE_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_PHONE_UPDATE]
	@ID			UNIQUEIDENTIFIER,
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
		UPDATE Client.CompanyPersonalPhone
		SET ID_TYPE	=	@TYPE,
			PHONE	=	@PHONE,
			PHONE_S	=	@PHONE_S,
			NOTE	=	@NOTE,
			UPD_DATE=	GETDATE(),
			UPD_USER=	ORIGINAL_LOGIN()
		WHERE ID	=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_PHONE_UPDATE] TO rl_company_personal_w;
GO
