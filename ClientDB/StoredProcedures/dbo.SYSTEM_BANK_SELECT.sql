USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANK_SELECT]
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
			a.InfoBankID, InfoBankShortName, InfoBankName,
			CONVERT(BIT,
				(
					SELECT COUNT(*)
					FROM dbo.SystemBankTable b
					WHERE a.InfoBankID = b.InfoBankID
						AND SystemID = @ID
				)
			) AS InfoBankChecked
		FROM
			dbo.InfoBankTable a
		ORDER BY InfoBankShortName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANK_SELECT] TO rl_system_bank_r;
GRANT EXECUTE ON [dbo].[SYSTEM_BANK_SELECT] TO rl_system_r;
GO
