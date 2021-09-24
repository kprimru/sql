USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_GET]
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
			(
				SELECT ID_PERSONAL
				FROM Client.CompanyProcess
				WHERE ID_COMPANY = @ID
					AND PROCESS_TYPE = N'PHONE'
					AND EDATE IS NULL
			) AS ID_PHONE,
			(
				SELECT ID_PERSONAL
				FROM Client.CompanyProcess
				WHERE ID_COMPANY = @ID
					AND PROCESS_TYPE = N'SALE'
					AND EDATE IS NULL
			) AS ID_SALE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_GET] TO rl_company_group;
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_GET] TO rl_company_process_w;
GO
