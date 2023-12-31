USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GET_INFOBANKS_FOR_COMPLECT_DEMO]
	@SYSID INT
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

		select I.InfoBankID, I.InfoBankName, I.InfoBankShortName,I.InfobankPath  FROM dbo.SystemsBanks SB

		INNER JOIN dbo.InfoBankTable I ON SB.InfoBank_Id = I.InfoBankID
		WHERE (SB.Required in (1)) AND SB.System_ID = @SYSID AND SB.DistrType_Id = 3 AND
		 I.InfoBankActive=1  AND I.InfobankPath <> ''

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_INFOBANKS_FOR_COMPLECT_DEMO] TO public;
GO
