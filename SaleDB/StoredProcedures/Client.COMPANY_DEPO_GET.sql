USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_GET]
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
			[DateFrom],
			[DateTo],
			[Number],
			[ExpireDate],
			[Status_Id],
			[Depo:Name],
			[Depo:Inn],
			[Depo:Region],
			[Depo:City],
			[Depo:Address],
			[Depo:Person1FIO],
			[Depo:Person1Phone],
			[Depo:Person2FIO],
			[Depo:Person2Phone],
			[Depo:Person3FIO],
			[Depo:Person3Phone],
			[Depo:Rival]
		FROM Client.CompanyDepo				AS D
		WHERE D.Id = @ID;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DEPO_GET] TO rl_depo_r;
GO
