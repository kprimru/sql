USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[ROLES_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[ROLES_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[ROLES_SELECT]
	@SH_ID	UNIQUEIDENTIFIER,
	@LGN	NVARCHAR(128)
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

		DECLARE @XML XML

		DECLARE @R NVARCHAR(MAX)

		SELECT @R = ROLES
		FROM Subhost.Users
		WHERE ID_SUBHOST = @SH_ID AND NAME = @LGN

		SET @XML = CAST(@R AS XML)

		SELECT c.value('(@name)', 'NVARCHAR(128)') AS RL_NAME
		FROM @XML.nodes('/root/role') a(c)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[ROLES_SELECT] TO rl_web_subhost;
GO
