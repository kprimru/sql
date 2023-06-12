USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_SERVICE_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_SERVICE_EDIT]  AS SELECT 1')
GO





/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_SERVICE_EDIT]
	@dsid SMALLINT,
	@dsname VARCHAR(100),
	@statusid SMALLINT,
	@subhost BIT,
	@dsreport BIT,
	@active BIT = 1
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

		UPDATE dbo.DistrServiceStatusTable
		SET DSS_NAME = @dsname,
			DSS_ID_STATUS = @statusid,
			DSS_SUBHOST = @subhost,
			DSS_REPORT = @dsreport,
			DSS_ACTIVE = @active
		WHERE DSS_ID = @dsid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_SERVICE_EDIT] TO rl_distr_service_w;
GO
