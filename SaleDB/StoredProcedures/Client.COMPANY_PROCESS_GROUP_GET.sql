USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_GROUP_GET]
	@LIST	NVARCHAR(MAX)
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
				SELECT COUNT(*)
				FROM
					Client.CompanyProcess a
					INNER JOIN Common.TableGUIDFromXML(@LIST) b ON a.ID_COMPANY = b.ID
				WHERE PROCESS_TYPE = N'PHONE'
					AND EDATE IS NULL
			) AS PHONE_COUNT,
			(
				SELECT COUNT(*)
				FROM
					Client.CompanyProcess a
					INNER JOIN Common.TableGUIDFromXML(@LIST) b ON a.ID_COMPANY = b.ID
				WHERE PROCESS_TYPE = N'SALE'
					AND EDATE IS NULL
			) AS SALE_COUNT


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_GROUP_GET] TO rl_company_group;
GO