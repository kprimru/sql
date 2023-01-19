USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_INN_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_INN_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_INN_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@DEL	BIT,
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
		SELECT
			a.Id, a.[Inn], a.Note,
			1 AS STATUS,
			NULL AS CREATE_DATA,
			NULL AS UPDATE_DATA,
			NULL AS DELETE_DATA
		FROM
			Client.CompanyInn a
		WHERE a.Company_Id = @ID;

		SELECT @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_INN_SELECT] TO rl_inn_r;
GO
