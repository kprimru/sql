USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[HOSTS_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[HOSTS_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[HOSTS_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT HostID, HostShort, HostReg, HostOrder
		FROM dbo.Hosts
		WHERE
			(HostReg LIKE @FILTER OR HostShort LIKE @FILTER)
			OR @FILTER IS NULL
		ORDER BY HostOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[HOSTS_SELECT] TO rl_hosts_r;
GO
