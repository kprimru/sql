USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[CompanyDepo@Set Status(Internal)]
	@GUIds		VarChar(Max),
	@Status_Id	SmallInt
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IDs Table
	(
		[Id]				UniqueIdentifier,
		PRIMARY KEY CLUSTERED([Id])
	);

	BEGIN TRY
		INSERT INTO @IDs
		SELECT DISTINCT [Id]
		FROM Common.TableGUIDFromXML(@GUIds);
		
		BEGIN TRAN;
		
		INSERT INTO Client.CompanyDepo(
				[Master_Id], [Company_Id], [DateFrom], [DateTo], [Number], [ExpireDate], [Status_Id],
				[Depo:Name], [Depo:Inn], [Depo:Region], [Depo:City], [Depo:Address], 
				[Depo:Person1FIO], [Depo:Person1Phone], [Depo:Person2FIO], [Depo:Person2Phone], 
				[Depo:Person3FIO], [Depo:Person3Phone], [Depo:Rival], [Status], [UpdDate], [UpdUser])
		SELECT
			D.[Id], D.[Company_Id], D.[DateFrom], D.[DateTo], D.[Number], D.[ExpireDate], D.[Status_Id],
			D.[Depo:Name], D.[Depo:Inn], D.[Depo:Region], D.[Depo:City], D.[Depo:Address],
			D.[Depo:Person1FIO], D.[Depo:Person1Phone], D.[Depo:Person2FIO], D.[Depo:Person2Phone],
			D.[Depo:Person3FIO], D.[Depo:Person3Phone], D.[Depo:Rival], 2, GetDate(), Original_Login()
		FROM @IDs						AS I
		INNER JOIN Client.CompanyDepo	AS D ON I.[Id] = D.[Id];
		
		UPDATE D
		SET [Status_Id] 	= @Status_Id,
			[UpdDate]		= GetDate(),
			[UpdUser]		= Original_Login()
		FROM Client.CompanyDepo 				AS D
		INNER JOIN @IDs							AS I ON D.[Id] = I.[Id];
					
		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;
			
		EXEC [Maintenance].[ReRaise Error];
	END CATCH	
END
