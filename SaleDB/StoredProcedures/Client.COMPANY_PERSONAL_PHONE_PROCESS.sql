USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PERSONAL_PHONE_PROCESS]
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
		IF @ID IS NULL
			EXEC Client.COMPANY_PERSONAL_PHONE_INSERT @PERSONAL, @TYPE, @PHONE, @PHONE_S, @NOTE
		ELSE
			EXEC Client.COMPANY_PERSONAL_PHONE_UPDATE @ID, @PERSONAL, @TYPE, @PHONE, @PHONE_S, @NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PERSONAL_PHONE_PROCESS] TO rl_company_personal_w;
GO
