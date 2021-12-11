USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CALL_NOTE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CALL_NOTE]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[CALL_NOTE]
	@PARAM	NVARCHAR(MAX) = NULL
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
			CC_DATE AS [Дата звонка], ClientFullName AS [Клиент], CC_PERSONAL AS [Сотрудник],
			CC_NOTE AS [Примечание], CC_USER AS [Кто звонил], CC_SERVICE AS [СИ]
		FROM
			dbo.ClientCall a
			INNER JOIN dbo.ClientView b ON a.CC_ID_CLIENT = b.ClientID
		WHERE CC_NOTE <> ''
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
GRANT EXECUTE ON [Report].[CALL_NOTE] TO rl_report;
GO
