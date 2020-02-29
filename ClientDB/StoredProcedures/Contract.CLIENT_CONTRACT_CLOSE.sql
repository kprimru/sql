USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_CLOSE]
	@Contract_Id		UniqueIdentifier,
	@DateTo				SmallDateTime,
	@DocumentExists		Bit,
	@DocumentType_Id	UniqueIdentifier,
	@DocumentDate		SmallDateTime,
	@DocumentNote		VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		BEGIN TRAN;
		
		UPDATE [Contract].[Contract]
		SET [DateTo] = @DateTo
		WHERE [ID] = @Contract_Id
			AND [DateTo] IS NULL;
				
		IF @@RowCount != 1
			RaisError('���������� ������! ������� ��� ������', 16, 1);
				
		IF @DocumentExists = 1
			INSERT INTO [Contract].[ClientContractsDocuments]([Contract_Id], [RowIndex], [Type_Id], [Date], [Note])
			SELECT
				@Contract_Id,
				IsNull((SELECT Max([RowIndex]) + 1 FROM [Contract].[ClientContractsDocuments] WHERE [Contract_Id] = @Contract_Id), 1),
				@DocumentType_Id, @DocumentDate, @DocumentNote;

		IF @@TranCount > 0
			COMMIT TRAN;
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;
			
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH;
END
