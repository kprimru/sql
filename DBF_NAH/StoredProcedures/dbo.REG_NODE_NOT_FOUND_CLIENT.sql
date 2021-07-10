USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[REG_NODE_NOT_FOUND_CLIENT]
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
			CASE RN_COMP_NUM
				WHEN 1 THEN RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM)
				ELSE RN_SYS_NAME + ' ' + CONVERT(VARCHAR, RN_DISTR_NUM) + '/' + CONVERT(VARCHAR, RN_COMP_NUM)
			END AS RN_DISTR_NUM,
			SST_CAPTION, DS_NAME, RN_COMMENT, RN_REG_DATE, RN_COMPLECT
		FROM
			dbo.RegNodeTable a LEFT OUTER JOIN
			dbo.SystemTypeTable ON SST_NAME = RN_DISTR_TYPE LEFT OUTER JOIN
			dbo.DistrStatusTable ON DS_REG = RN_SERVICE
		WHERE
			NOT EXISTS
					(
						SELECT *
						FROM dbo.DistrView b WITH(NOEXPAND)
						WHERE
							DIS_NUM = RN_DISTR_NUM AND
							DIS_COMP_NUM = RN_COMP_NUM AND
							SYS_REG_NAME = RN_SYS_NAME AND
							DIS_ACTIVE = 1
					) AND
			RN_DISTR_TYPE NOT IN
							(
								SELECT 'NCT'
								UNION ALL
								SELECT 'NEK'
								UNION
								SELECT 'HSS'
							)
		ORDER BY RN_SERVICE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REG_NODE_NOT_FOUND_CLIENT] TO rl_audit_reg_node_r;
GO