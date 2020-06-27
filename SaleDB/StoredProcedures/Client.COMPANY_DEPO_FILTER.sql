USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_FILTER]
	@Statuses	VarChar(Max)	= NULL,
	@ExpireDate	SmallDateTime	= NULL,
	@Number     Int             = NULL,
	@Name       VarChar(100)    = NULL,
	@FileName	VarChar(250)	= NULL OUTPUT,
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
		@Status_NEW				SmallInt,
		@Status_TAG				SmallInt,
		@Status_TERMINATION		SmallInt,
		@Status_STAGE			SmallInt;

	DECLARE @TStatuses Table ([Id] Smallint NOT NULL PRIMARY KEY CLUSTERED);

	BEGIN TRY
		SET @Status_NEW = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'NEW');
		SET @Status_TAG = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'TAG');
		SET @Status_TERMINATION = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'TERMINATION');
		SET @Status_STAGE = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');

		IF LTrim(Rtrim(@Name)) = ''
		    SET @Name = NULL
		ELSE
		    SET @Name = '%' + Replace(@Name, ' ', '%') + '%';

		INSERT INTO @TStatuses
		SELECT [Id] FROM Common.TableIDFromXML(@Statuses);

		IF (SELECT Count(*) FROM @TStatuses) = 1 BEGIN
			IF EXISTS(SELECT * FROM @TStatuses WHERE [Id] = @Status_NEW)
				SET @FileName = 'Список NEW РИЦ 020 за ' + DateName(MONTH, GetDate()) + ' ' + Cast(DatePart(Year, GetDate()) AS VarChar(10))
			ELSE IF EXISTS(SELECT * FROM @TStatuses WHERE [Id] = @Status_TAG)
				SET @FileName = 'Список TAG РИЦ 020 за ' + DateName(MONTH, GetDate()) + ' ' + Cast(DatePart(Year, GetDate()) AS VarChar(10))
			ELSE IF EXISTS(SELECT * FROM @TStatuses WHERE [Id] = @Status_TERMINATION)
				SET @FileName = 'Список OUT РИЦ 020 за ' + DateName(MONTH, GetDate()) + ' ' + Cast(DatePart(Year, GetDate()) AS VarChar(10))
			ELSE
				SET @FileName = ''
		END
		ELSE
			SET @FileName = ''

		SELECT
			D.[Id],
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
			[Depo:Rival],
			--
			[Depo:Stage] = Cast(CASE WHEN DS.[Id] IS NOT NULL THEN 1 ELSE 0 END AS Bit)
		FROM Client.CompanyDepo				AS D
		INNER JOIN Client.[Depo->Statuses]	AS S ON D.[Status_Id] = S.[Id]
		OUTER APPLY
		(
			SELECT TOP (1)
				DS.[Id]
			FROM Client.CompanyDepo				AS DS
			WHERE DS.[Company_Id] = D.[Company_Id]
				AND DS.[Status_Id] = @Status_STAGE
				AND DS.STATUS = 1
		) AS DS
		WHERE D.STATUS = 1
			AND (@Statuses IS NULL OR D.[Status_Id] IN (SELECT [Id] FROM @TStatuses))
			AND (D.[ExpireDate] = @ExpireDate OR @ExpireDate IS NULL)
			AND D.[Status_Id] NOT IN (@Status_STAGE)
			AND (D.[Number] = @Number OR @Number IS NULL)
			AND (D.[Depo:Name] LIKE @Name OR @Name IS NULL)
		ORDER BY D.[Number] DESC, D.[DateFrom] DESC

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
GRANT EXECUTE ON [Client].[COMPANY_DEPO_FILTER] TO rl_depo_filter;
GO