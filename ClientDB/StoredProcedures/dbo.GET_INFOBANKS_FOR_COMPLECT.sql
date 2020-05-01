USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GET_INFOBANKS_FOR_COMPLECT]
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

		SELECT InfoBankName, InfoBankShortName, InfoBankFullName, InfoBankPath
		FROM dbo.InfoBankTable
		WHERE
			InfoBankID IN
				(
					SELECT InfoBankID
					FROM dbo.SystemBankTable
					--WHERE  (SystemID = @SYSID) AND (Required IN (1, 2)) --ДОФ будем добавлять программно
					WHERE  (SystemID = @SYSID) AND  (Required IN (1, 2) )
				)
			AND InfoBankActive = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[GET_INFOBANKS_FOR_COMPLECT] TO public;
GO