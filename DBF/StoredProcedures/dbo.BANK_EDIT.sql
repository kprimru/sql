USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

ALTER PROCEDURE [dbo].[BANK_EDIT] 
	@bankid  SMALLINT,
	@bankname VARCHAR(150),
	@cityid INT,
	@bankphone VARCHAR(100),	
	@bankmfo VARCHAR(100),	
	@bankcalc VARCHAR(100),	
	@bik VARCHAR(50),
	@loro VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.BankTable 
		SET BA_NAME = @bankname, 
			BA_ID_CITY = @cityid, 
			BA_PHONE = @bankphone, 
			BA_CALC = @bankcalc, 
			BA_MFO = @bankmfo,
			BA_BIK = @bik,
			BA_LORO = @loro,
			BA_ACTIVE = @active
		WHERE BA_ID = @bankid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[BANK_EDIT] TO rl_bank_w;
GO