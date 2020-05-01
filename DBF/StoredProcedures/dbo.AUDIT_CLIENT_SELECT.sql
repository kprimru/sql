USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[AUDIT_CLIENT_SELECT]
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

		IF DB_ID('DBF_NAH') IS NOT NULL
			SELECT
				CL_ID, CL_PSEDO, TO_ID, TO_NUM, DIS_ID, DIS_STR, CL_ERROR,
				(SELECT COUNT(*) FROM DBF_NAH.dbo.TOTable z WHERE z.TO_NUM = a.TO_NUM) AS TO_NAH,
				(SELECT COUNT(*) FROM DBF_NAH.dbo.ClientTable z WHERE z.CL_NUM = a.CL_NUM) AS CL_NAH
			FROM dbo.AuditClientView a
			ORDER BY CL_ERROR, CL_PSEDO, CL_ID
		ELSE
			SELECT
				CL_ID, CL_PSEDO, TO_ID, TO_NUM, DIS_ID, DIS_STR, CL_ERROR,
				0 AS TO_NAH, 0 AS CL_NAH
			FROM dbo.AuditClientView
			ORDER BY CL_ERROR, CL_PSEDO, CL_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[AUDIT_CLIENT_SELECT] TO rl_audit_client;
GRANT EXECUTE ON [dbo].[AUDIT_CLIENT_SELECT] TO rl_audit_client_r;
GO