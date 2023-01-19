USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REG_NODE_VERIFY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REG_NODE_VERIFY]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[REG_NODE_VERIFY]
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

		SELECT CL_ID, CL_PSEDO, DIS_STR, DSS_NAME, DIS_SERVICE
		FROM
			(
				SELECT
					CL_ID, CL_PSEDO, DIS_STR, DSS_NAME, DSS_REPORT, DIS_SERVICE
				FROM
					dbo.ClientDistrTable INNER JOIN
					dbo.ClientTable ON CL_ID = CD_ID_CLIENT INNER JOIN
					dbo.DistrServiceView ON DIS_ID = CD_ID_DISTR INNER JOIN
					dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
					dbo.DistrStatusTable ON DS_ID = DSS_ID_STATUS
				WHERE DS_REG <> RN_SERVICE
			) AS CL
		ORDER BY CL_PSEDO, DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REG_NODE_VERIFY] TO rl_audit_distr_r;
GO
