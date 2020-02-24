USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_DEPO_FILTER]
	@Statuses	VarChar(Max),
	@RC			INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
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
			[Depo:Rival]
		FROM Client.CompanyDepo				AS D
		INNER JOIN Client.[Depo->Statuses]	AS S ON D.[Status_Id] = S.[Id]
		WHERE @Statuses IS NULL OR D.[Status_Id] IN (SELECT [Id] FROM Common.TableIDFromXML(@Statuses))
		ORDER BY D.[DateFrom] DESC

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
