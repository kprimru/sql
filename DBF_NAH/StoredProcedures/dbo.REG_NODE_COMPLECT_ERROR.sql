USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REG_NODE_COMPLECT_ERROR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REG_NODE_COMPLECT_ERROR]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[REG_NODE_COMPLECT_ERROR]
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

		SELECT
			RN_COMPLECT, DIS_STR, TO_NAME, TO_NUM, CL_ID, CL_PSEDO, TO_ID, DS_NAME
		FROM
			dbo.RegNodeTable a INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON
						RN_SYS_NAME = SYS_REG_NAME AND
						DIS_NUM = RN_DISTR_NUM AND
						DIS_COMP_NUM = RN_COMP_NUM INNER JOIN
			dbo.TODistrTable ON TD_ID_DISTR = DIS_ID INNER JOIN
			dbo.TOTable ON TO_ID = TD_ID_TO INNER JOIN
			dbo.ClientTable ON CL_ID = TO_ID_CLIENT INNER JOIN
			dbo.DistrStatusTable ON DS_REG = RN_SERVICE
		WHERE RN_COMPLECT IS NOT NULL 
			AND
				(
					SELECT COUNT(DISTINCT TO_ID)
					FROM
						dbo.TOTable INNER JOIN
						dbo.TODistrTable ON TO_ID = TD_ID_TO INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
						dbo.RegNodeTable b ON
										RN_DISTR_NUM = DIS_NUM AND
										RN_COMP_NUM = DIS_COMP_NUM AND
										RN_SYS_NAME = SYS_REG_NAME
					WHERE b.RN_COMPLECT = a.RN_COMPLECT
				) > 1
			AND EXISTS
				(
					SELECT *
					FROM
						dbo.TOTable INNER JOIN
						dbo.TODistrTable ON TO_ID = TD_ID_TO INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
						dbo.RegNodeTable b ON
										RN_DISTR_NUM = DIS_NUM AND
										RN_COMP_NUM = DIS_COMP_NUM AND
										RN_SYS_NAME = SYS_REG_NAME
					WHERE b.RN_COMPLECT = a.RN_COMPLECT
						AND b.RN_SERVICE = 0
				)
		ORDER BY RN_COMPLECT, TO_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REG_NODE_COMPLECT_ERROR] TO rl_audit_reg_node_r;
GO
