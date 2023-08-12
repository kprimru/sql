﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INFO_BANK_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INFO_BANK_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[INFO_BANK_GET]
	@ID	INT
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

		SELECT
			InfoBankID, InfoBankName, InfoBankShortName, InfoBankFullName,
			InfoBankOrder, InfoBankPath, InfoBankActive, InfoBankDaily,
			InfoBankActual, InfoBankStart
		FROM dbo.InfoBankTable
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
GRANT EXECUTE ON [dbo].[INFO_BANK_GET] TO rl_info_bank_r;
GO
