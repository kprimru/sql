USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INFO_BANK_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INFO_BANK_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[INFO_BANK_SELECT]
	@FILTER	VARCHAR(150) = NULL,
	@INFO_BANK_ACTIVE	BIT = NULL
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
			InfoBankID, InfoBankShortName, InfoBankName, InfoBankDaily, InfoBankActual,
			InfoBankStart,
			dbo.FileByteSizeToStr(
				(
					SELECT TOP 1 IBS_SIZE
					FROM dbo.InfoBankSizeView WITH(NOEXPAND)
					WHERE IBF_ID_IB = InfoBankID
					ORDER BY IBS_DATE DESC
				)
			) AS IBS_SIZE
		FROM dbo.InfoBankTable
		WHERE (@FILTER IS NULL
			OR InfoBankShortName LIKE @FILTER
			OR InfoBankName LIKE @FILTER
			OR InfoBankFullName LIKE @FILTER)
			AND (InfoBankActive = @INFO_BANK_ACTIVE OR
				@INFO_BANK_ACTIVE IS NULL)
		ORDER BY InfoBankName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END

GO
GRANT EXECUTE ON [dbo].[INFO_BANK_SELECT] TO rl_info_bank_r;
GO
