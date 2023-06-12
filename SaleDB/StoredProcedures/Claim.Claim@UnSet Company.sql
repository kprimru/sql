USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claim@UnSet Company]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claim@UnSet Company]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[Claim@UnSet Company]
    @Id             Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Company_Id     UniqueIdentifier,
        @Email              VarChar(100),
		@Phone              VarChar(100),
        @FIO                VarChar(255),
        @Special            VarChar(1024);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

		SELECT
            @Email      = [EMail],
            @FIO        = [FIO],
            @Special    = IsNull([Special], ''),
			@Phone      = Replace([Phone], '+7', '8')
        FROM [Claim].[Claims] AS C
        WHERE [Id] = @Id;

        UPDATE [Client].[Company] SET
            SENDER_NOTE = NULL
        WHERE ID IN (SELECT [Company_Id] FROM [Claim].[Claims:Companies] WHERE [Claim_Id] = @Id);

		DELETE
		FROM [Client].[CompanyPersonalPhone]
		WHERE [ID_PERSONAL] IN
			(
				SELECT CP.[ID]
				FROM [Client].[CompanyPersonal] AS CP
				WHERE CP.[ID_COMPANY] IN (SELECT [Company_Id] FROM [Claim].[Claims:Companies] WHERE [Claim_Id] = @Id)
					AND [NAME] = @FIO
					AND IsNull([NOTE], '') = @Special
			);

		DELETE
		FROM [Client].[CompanyPersonal]
		WHERE ID_COMPANY IN (SELECT [Company_Id] FROM [Claim].[Claims:Companies] WHERE [Claim_Id] = @Id)
			AND [NAME] = @FIO
			AND IsNull([NOTE], '') = @Special;

        DELETE FROM [Claim].[Claims:Companies]
        WHERE [Claim_Id] = @Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        IF @@TranCount > 0
            ROLLBACK TRAN;

        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claim@UnSet Company] TO rl_claim_unset_company;
GO
