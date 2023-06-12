USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_PRINT_PERSONAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_PRINT_PERSONAL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_PRINT_PERSONAL_SELECT]
	@LIST	VARCHAR(MAX)
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

		DECLARE @CLIENT	TABLE(CL_ID INT PRIMARY KEY)

		INSERT INTO @CLIENT
			SELECT ID
			FROM dbo.TableIDFromXML(@LIST)

		SELECT
			CL_ID,
			CPT_SHORT, ISNULL(CP_SURNAME, '') +
			CASE ISNULL(CP_NAME, '')
				WHEN '' THEN ''
				ELSE ' ' + CP_NAME
			END +
			CASE ISNULL(CP_PATRON, '')
				WHEN '' THEN ''
				ELSE ' ' + CP_PATRON
			END AS CP_FIO, CP_POS, CP_NOTE,
			CP_PHONE, CP_EMAIL,
			CP_FAX
		FROM
			@CLIENT
			INNER JOIN dbo.ClientPersonal ON CP_ID_CLIENT = CL_ID
			LEFT OUTER JOIN dbo.ClientPersonalType ON CPT_ID = CP_ID_TYPE
		--ORDER BY CL_ID, ISNULL(CPT_REQUIRED, 0) DESC, CPT_ORDER, CP_SURNAME, CP_NAME
		ORDER BY CL_ID, CPT_REQUIRED DESC, CPT_ORDER, CP_SURNAME, CP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PRINT_PERSONAL_SELECT] TO rl_client_p;
GO
