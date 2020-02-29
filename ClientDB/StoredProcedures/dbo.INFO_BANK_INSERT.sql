USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INFO_BANK_INSERT]	
	@NAME	VARCHAR(20),
	@SHORT	VARCHAR(20),
	@FULL	VARCHAR(250),
	@ORDER	INT,
	@PATH	VARCHAR(255),
	@ACTIVE	BIT,
	@DAILY	BIT,
	@ACTUAL	BIT,	
	@ID	INT = NULL OUTPUT,
	@START	SMALLDATETIME = NULL
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

		INSERT INTO dbo.InfoBankTable(
			InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, 
			InfoBankPath, InfoBankActive, InfoBankDaily, InfoBankActual, InfoBankStart)
		VALUES(@NAME, @SHORT, @FULL, @ORDER, @PATH, @ACTIVE, @DAILY, @ACTUAL, @START)
		
		SELECT @ID = SCOPE_IDENTITY()
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
