USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DBF_SEARCH]
	@NAME	VARCHAR(250),
	@DISTR	INT
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

		SELECT TOP 100 TO_ID, TO_NUM, TO_NAME, COUR_NAME, TA_STR, DIS_LIST
		FROM dbo.DBFTOView
		WHERE (TO_NAME LIKE @NAME OR @NAME IS NULL)
			AND (@DISTR IS NULL OR
					EXISTS
						(
							SELECT *
							FROM dbo.DBFTODistrView
							WHERE DIS_NUM = @DISTR
								AND TD_ID_TO = TO_ID
						)
				)
		ORDER BY TO_NUM DESC, TO_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DBF_SEARCH] TO rl_client_dbf_import;
GO
