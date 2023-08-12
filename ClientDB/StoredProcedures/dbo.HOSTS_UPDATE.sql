USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[HOSTS_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[HOSTS_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[HOSTS_UPDATE]
	@ID	INT,
	@SHORT	VARCHAR(50),
	@REG	VARCHAR(50),
	@ORDER	INT
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

		UPDATE dbo.Hosts
		SET HostShort = @SHORT,
			HostReg = @REG,
			HostOrder = @ORDER
		WHERE HostID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[HOSTS_UPDATE] TO rl_hosts_u;
GO
