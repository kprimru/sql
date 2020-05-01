USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_GET]
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
			SystemShortName, SystemName, SystemBaseName, SystemNumber,
			HostID, SystemRic, SystemOrder, SystemVMI, SystemFullName,
			SystemActive, SystemDemo, SystemComplect, SystemReg, SystemSalaryWeight,
			('<LIST>' +
				(
					SELECT CONVERT(VARCHAR(50), InfoBankID)AS ITEM
					FROM dbo.SystemBanksView b WITH(NOEXPAND)
					WHERE a.SystemID = b.SystemID AND Required = 1
					ORDER BY InfoBankID FOR XML PATH('')
				)
			+ '</LIST>') AS IB_REQ_ID,
			('<LIST>' +
				(
					SELECT CONVERT(VARCHAR(50), InfoBankID)AS ITEM
					FROM dbo.SystemBanksView b WITH(NOEXPAND)
					WHERE a.SystemID = b.SystemID AND Required = 0
					ORDER BY InfoBankID FOR XML PATH('')
				)
			+ '</LIST>') AS IB_ID
		FROM dbo.SystemTable a
		WHERE SystemID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SYSTEM_GET] TO rl_system_r;
GO