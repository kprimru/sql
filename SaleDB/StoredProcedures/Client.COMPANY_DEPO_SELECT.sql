USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_SELECT]
	@ID		UNIQUEIDENTIFIER,
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
			D.[Id],
			D.[Status_Id],
			[Company_Id],
			[DateFrom],
			[DateTo],
			[Number],
			[ExpireDate],
			S.[Name],
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
		INNER JOIN Client.[Depo->Statuses]	AS S ON D.[Status_Id] = S.[Id]
		WHERE D.Company_Id = @ID
			AND D.[Status] = 1
		ORDER BY D.[DateFrom] DESC

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
GRANT EXECUTE ON [Client].[COMPANY_DEPO_SELECT] TO rl_depo_r;
GO
