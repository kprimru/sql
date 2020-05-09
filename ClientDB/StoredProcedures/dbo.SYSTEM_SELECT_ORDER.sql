USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_SELECT_ORDER]
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
			a.SystemID, SystemShortName, SystemOrder,
			(
				SELECT COUNT(*)
				FROM dbo.SystemTable
			) AS SystemCount,
			c.InfoBankID, InfoBankShortName,
			ROW_NUMBER() OVER(PARTITION BY SystemOrder ORDER BY InfoBankOrder, c.InfoBankID) AS InfoBankOrder,
			(
				SELECT COUNT(*)
				FROM dbo.SystemBankTable z
				WHERE z.SystemID = a.SystemID
			) AS InfoBankCount
		FROM
			(
				SELECT SystemID, SystemShortName, ROW_NUMBER() OVER(ORDER BY SystemOrder, SystemID) AS SystemOrder
				FROM dbo.SystemTable
			) AS a INNER JOIN dbo.SystemBankTable b ON a.SystemID = b.SystemID
			INNER JOIN dbo.InfoBankTable c ON c.InfoBankID = b.InfoBankID
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
GRANT EXECUTE ON [dbo].[SYSTEM_SELECT_ORDER] TO rl_system_order;
GO