USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_SELECT]
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
			CP_ID, CPT_ID, CPT_NAME, CPT_REQUIRED, CPT_PSEDO,
			CASE ISNULL(CP_SURNAME, '')
				WHEN '' THEN ''
				ELSE CP_SURNAME + ' '
			END + 
			CASE ISNULL(CP_NAME, '')
				WHEN '' THEN ''
				ELSE CP_NAME + ' '
			END +
			ISNULL(CP_PATRON, '') CP_FIO,
			CP_SURNAME, CP_NAME, CP_PATRON,
			CP_POS, CP_NOTE,
			CP_PHONE, CP_EMAIL,
			NULL AS CP_MAP, CP_FAX,/*,
			CASE
				WHEN CP_MAP IS NOT NULL THEN '����'
				ELSE '���'
			END AS CP_MAP_EXISTS*/
			'' AS CP_MAP_EXISTS
		FROM
			dbo.ClientPersonal
			LEFT OUTER JOIN dbo.ClientPersonalType ON CPT_ID = CP_ID_TYPE
		WHERE CP_ID_CLIENT = @ID
		ORDER BY CPT_REQUIRED DESC, CPT_ORDER, CP_SURNAME, CP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_SELECT] TO rl_client_card;
GO
