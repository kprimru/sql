USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INFO_BANKS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INFO_BANKS_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[INFO_BANKS_SELECT]
	@SYSTEM	INT
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
            InfoBankID, InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankOrder, InfoBankPath, InfoBankActive,
            SystemID, SystemFullName, SystemActive, SystemOrder, SystemShortName, SystemBaseName, Required, HostID, InfoBankStart
		FROM dbo.SystemBankGet(@SYSTEM, 2) a
		ORDER BY InfoBankOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INFO_BANKS_SELECT] TO public;
GO
