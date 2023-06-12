USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_SERVICE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_SERVICE_GET]  AS SELECT 1')
GO



/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_SERVICE_GET]
	@dsid SMALLINT = NULL
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

		SELECT DSS_NAME, DSS_ID, DSS_SUBHOST, DS_ID, DS_NAME, DSS_REPORT, DSS_ACTIVE
		FROM
			dbo.DistrServiceStatusTable LEFT OUTER JOIN
			dbo.DistrStatusTable ON DS_ID = DSS_ID_STATUS
		WHERE DSS_ID = @dsid
		ORDER BY DSS_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_SERVICE_GET] TO rl_distr_service_r;
GO
