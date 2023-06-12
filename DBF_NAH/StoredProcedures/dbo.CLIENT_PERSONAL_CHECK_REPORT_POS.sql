USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_PERSONAL_CHECK_REPORT_POS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_CHECK_REPORT_POS]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_CHECK_REPORT_POS]
	@clientid INT,
	@reportposid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT PER_ID
		FROM dbo.ClientPersonalTable
		WHERE PER_ID_CLIENT = @clientid AND PER_ID_REPORT_POS = @reportposid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_CHECK_REPORT_POS] TO rl_client_personal_w;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_CHECK_REPORT_POS] TO rl_client_w;
GO
