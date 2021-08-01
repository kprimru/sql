USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_STAGE_FILTER]
    @Number     Int             = NULL,
	@Name       VarChar(100)    = NULL,
	@RC			Int				= NULL OUTPUT
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

	DECLARE
		@Status_STAGE			SmallInt;

	BEGIN TRY
		SET @Status_STAGE = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');

		IF LTrim(Rtrim(@Name)) = ''
		    SET @Name = NULL
		ELSE
		    SET @Name = '%' + Replace(@Name, ' ', '%') + '%';

		SELECT
			D.[Id],
			[Company_Id],
			[SortIndex],
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
			[Depo:Rival],
			[StatusName] = C.[Name]
		FROM Client.CompanyDepo				AS D
		OUTER APPLY
		(
		    SELECT TOP (1) S.Name
		    FROM Client.CompanyDepo AS C
		    INNER JOIN [Client].[Depo->Statuses] AS S ON C.Status_Id = S.[Id]
		    WHERE C.Company_Id = D.Company_Id
		        AND C.[Status_Id] NOT IN (@Status_STAGE)
		    ORDER BY C.[DateFrom] DESC
		) AS C
		WHERE D.STATUS = 1
			AND D.[Status_Id] IN (@Status_STAGE)
			AND (D.[SortIndex] = @Number OR @Number IS NULL)
			AND (D.[Depo:Name] LIKE @Name OR @Name IS NULL)
		--ORDER BY D.[SortIndex] DESC
		ORDER BY D.[SortIndex];

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
GRANT EXECUTE ON [Client].[COMPANY_DEPO_STAGE_FILTER] TO rl_depo_stage_filter;
GO