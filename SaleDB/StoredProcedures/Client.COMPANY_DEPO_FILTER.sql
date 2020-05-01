USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_FILTER]
	@Statuses	VarChar(Max)	= NULL,
	@ExpireDate	SmallDateTime	= NULL,
	@FileName	VarChar(250)	= NULL OUTPUT,
	@RC			Int				= NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

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
			AND (D.[ExpireDate] <= @ExpireDate OR @ExpireDate IS NULL)
			AND D.[Status_Id] NOT IN (@Status_STAGE)
		ORDER BY D.[Number] DESC, D.[DateFrom] DESC

		SELECT @RC = @@ROWCOUNT
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GRANT EXECUTE ON [Client].[COMPANY_DEPO_FILTER] TO rl_depo_filter;
GO