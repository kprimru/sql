USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTROL_SELECT]
	@CLIENT	INT
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
			CC_ID, CC_BEGIN, CC_TEXT, CC_DATE, CC_AUTHOR,
			CC_READ_DATE, CC_READER, CC_REMOVE_DATE, CC_REMOVER,
			CC_READER + ' ' + CONVERT(VARCHAR(20), CC_READ_DATE, 104) + ' ' + CONVERT(VARCHAR(20), CC_READ_DATE, 108) AS CC_READ,
			CC_REMOVER + ' ' + CONVERT(VARCHAR(20), CC_REMOVE_DATE, 104) + ' ' + CONVERT(VARCHAR(20), CC_REMOVE_DATE, 108) AS CC_REMOVE ,
			CASE CC_TYPE
				WHEN 1 THEN 'Аудит'
				WHEN 2 THEN 'Руководитель группы'
				WHEN 3 THEN 'Дежурная служба'
				WHEN 4 THEN 'Начальник отдела'
				WHEN 5 THEN 'Юрист'
				ELSE ''
			END AS CC_TYPE_STR
		FROM dbo.ClientControl
		WHERE CC_ID_CLIENT = @CLIENT
		ORDER BY CC_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTROL_SELECT] TO rl_client_control_r;
GO
