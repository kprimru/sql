USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[REG_PROTOCOL_USERS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Reg].[REG_PROTOCOL_USERS]  AS SELECT 1')
GO
ALTER PROCEDURE [Reg].[REG_PROTOCOL_USERS]
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

		SELECT DISTINCT RPR_USER
		FROM dbo.RegProtocol
		WHERE RPR_USER != ''
		ORDER BY RPR_USER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Reg].[REG_PROTOCOL_USERS] TO rl_reg_protocol_filter;
GO
