USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_STAGE_FILTER]
	@RC			Int				= NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Status_STAGE			SmallInt;

	BEGIN TRY
		SET @Status_STAGE = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');

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
			[Depo:Rival]
		FROM Client.CompanyDepo				AS D
		WHERE D.STATUS = 1
			AND D.[Status_Id] IN (@Status_STAGE)
		ORDER BY D.[SortIndex]

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
GRANT EXECUTE ON [Client].[COMPANY_DEPO_STAGE_FILTER] TO rl_depo_stage_filter;
GO