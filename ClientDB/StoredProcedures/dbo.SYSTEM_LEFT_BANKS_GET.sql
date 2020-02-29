USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE	[dbo].[SYSTEM_LEFT_BANKS_GET]
	@SYS_LIST			NVARCHAR(128),
	@DISTR_TYPE_LIST	NVARCHAR(128) 
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

		DECLARE @t	TABLE
		(
			InfoBank_ID			SMALLINT, 
			InfoBankName		VARCHAR(100), 
			InfoBankShortName	VARCHAR(100), 
			Required			BIT, 
			InfoBankOrder		INT
		)

		INSERT INTO @t
		EXEC [dbo].[SYSTEM_BANKS_GET] @SYS_LIST, @DISTR_TYPE_LIST

		SELECT InfoBankID, InfoBankName, InfoBankShortName, InfoBankOrder
		FROM InfoBankTable
		WHERE InfoBankID NOT IN (SELECT InfoBank_ID FROM @t)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

