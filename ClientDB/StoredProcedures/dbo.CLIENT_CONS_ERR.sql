USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONS_ERR]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT
WITH EXECUTE AS OWNER
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

		SELECT TOP 1 Replace(ERROR_DATA  Collate Cyrillic_General_BIN, Char(0), '') AS UF_ERROR_LOG
		FROM
			dbo.IPConsErrView b
			INNER JOIN dbo.SystemTable c ON b.UF_SYS = c.SystemNumber
		WHERE b.UF_DISTR = @DISTR AND b.UF_COMP = @COMP AND c.HostID = @HOST
		ORDER BY UF_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONS_ERR] TO rl_client_card;
GO
