USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INFO_BANK_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INFO_BANK_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[INFO_BANK_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(20),
	@SHORT	VARCHAR(20),
	@FULL	VARCHAR(250),
	@ORDER	INT,
	@PATH	VARCHAR(255),
	@ACTIVE	BIT,
	@DAILY	BIT,
	@ACTUAL	BIT,
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

		UPDATE dbo.InfoBankTable
		SET InfoBankName = @NAME,
			InfoBankShortName = @SHORT,
			InfoBankFullName = @FULL,
			InfoBankOrder = @ORDER,
			InfoBankPath = @PATH,
			InfoBankActive = @ACTIVE,
			InfoBankDaily = @DAILY,
			InfoBankActual = @ACTUAL,
			InfoBankStart = ISNULL(@START, InfoBankStart)
		WHERE InfoBankID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INFO_BANK_UPDATE] TO rl_info_bank_u;
GO
