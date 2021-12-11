USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_INFOBANKS_FOR_COMPLECT_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_INFOBANKS_FOR_COMPLECT_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[GET_INFOBANKS_FOR_COMPLECT_NEW]
	@SYSID INT,
    @SYSTYPE INT
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
		WHERE (SB.Required in (0,1)) AND SB.System_ID = @SYSID AND SB.DistrType_Id = @SYSTYPE AND
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
GRANT EXECUTE ON [dbo].[GET_INFOBANKS_FOR_COMPLECT_NEW] TO public;
GO
