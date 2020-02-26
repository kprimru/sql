USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_DOCUMENT_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@CONTRACT	INT,
	@TYPE		UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@NOTE		NVARCHAR(MAX),
	@FIXED		MONEY = NULL
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

		IF @ID IS NULL
			INSERT INTO dbo.ContractDocument(ID_CONTRACT, ID_TYPE, DATE, NOTE, FIXED)
				VALUES(@CONTRACT, @TYPE, @DATE, @NOTE, @FIXED)
		ELSE
		BEGIN
			INSERT INTO dbo.ContractDocument(ID_MASTER, ID_CONTRACT, ID_TYPE, DATE, NOTE, FIXED, STATUS, UPD_DATE, UPD_USER)
				SELECT @ID, ID_CONTRACT, ID_TYPE, DATE, NOTE, FIXED, 2, UPD_DATE, UPD_USER
				FROM dbo.ContractDocument
				WHERE ID = @ID
				
			UPDATE dbo.ContractDocument
			SET	ID_TYPE		=	@TYPE,
				DATE		=	@DATE,
				NOTE		=	@NOTE,
				FIXED		=	@FIXED,
				UPD_DATE	=	GETDATE(),
				UPD_USER	=	ORIGINAL_LOGIN()
			WHERE ID = @ID
		END	
		
		UPDATE dbo.ContractTable
		SET ContractFixed = (SELECT TOP 1 FIXED FROM dbo.ContractDocument WHERE ID_CONTRACT = @CONTRACT ORDER BY DATE DESC, UPD_DATE DESC)
		WHERE ContractID = @CONTRACT
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
