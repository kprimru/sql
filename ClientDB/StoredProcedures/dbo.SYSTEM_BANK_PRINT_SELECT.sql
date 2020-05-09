USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANK_PRINT_SELECT]
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
			a.SystemID, SystemShortName, SystemBaseName, SystemFullName, SystemNumber,
			(
				SELECT COUNT(*)
				FROM
					dbo.SystemBankTable z
					INNER JOIN dbo.InfoBankTable y ON y.InfoBankID = z.InfoBankID
				WHERE a.SystemID = z.SystemID AND y.InfoBankActive = 1
			) AS SYS_CNT,
			c.InfoBankID, InfoBankShortName, InfoBankFullName, InfoBankName
		FROM
			dbo.SystemTable a
			INNER JOIN dbo.SystemBankTable b ON a.SystemID = b.SystemID
			INNER JOIN dbo.InfoBankTable c ON c.InfoBankID = b.InfoBankID
		WHERE SystemActive = 1 AND InfoBankActive = 1
		ORDER BY SystemOrder, SystemID, InfoBankOrder, InfoBankID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANK_PRINT_SELECT] TO rl_system_r;
GO