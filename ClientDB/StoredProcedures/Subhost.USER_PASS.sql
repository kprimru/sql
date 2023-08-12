USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[USER_PASS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[USER_PASS]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [Subhost].[USER_PASS]
	@SH_ID	UNIQUEIDENTIFIER,
	@LGN	NVARCHAR(128),
	@PASS	NVARCHAR(128)
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

		UPDATE Subhost.Users
		SET PASS = @PASS
		WHERE NAME = @LGN
			AND ID_SUBHOST = @SH_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[USER_PASS] TO rl_web_subhost;
GO
