USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_STATUS_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@REG	SMALLINT,
	@Code	VarChar(100),
	@INDEX	INT,
	@DEF	INT
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

		UPDATE dbo.ServiceStatusTable
		SET ServiceStatusName = @NAME,
			ServiceStatusReg = @REG,
			ServiceCode	= @Code,
			ServiceStatusIndex = @INDEX,
			ServiceDefault = @DEF
		WHERE ServiceStatusID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SERVICE_STATUS_UPDATE] TO rl_status_u;
GO