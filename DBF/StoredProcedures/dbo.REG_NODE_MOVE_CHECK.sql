USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[REG_NODE_MOVE_CHECK]
	@periodid SMALLINT
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

		DECLARE @HOST SMALLINT
		SELECT @HOST = HST_ID
		FROM dbo.HostTable
		WHERE HST_REG_NAME = 'LAW'

		DECLARE @ERR NVARCHAR(MAX)

		SELECT @ERR =
		(
			SELECT 'Отсутствует вес системы "' + SYS_SHORT_NAME + ' :: ' + SST_CAPTION + ' :: ' + SNC_SHORT + '"' + CHAR(10)
			FROM
			(
				SELECT DISTINCT RN_ID_SYSTEM, RN_ID_TYPE, RN_ID_NET
				FROM dbo.RegNodeFullTable R
				INNER JOIN dbo.SystemTable S ON R.RN_ID_SYSTEM = S.SYS_ID
				INNER JOIN dbo.DistrStatusTable D ON D.DS_ID = R.RN_ID_STATUS
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.WeightRules W
						WHERE W.ID_PERIOD = @periodid
							AND R.RN_ID_SYSTEM = W.ID_SYSTEM
							AND R.RN_ID_TYPE = W.ID_TYPE
							AND R.RN_ID_NET = W.ID_NET
					)
					AND SYS_ID_HOST = @HOST
					AND DS_REG = 0
			) AS A
			INNER JOIN dbo.SystemTable ON RN_ID_SYSTEM = SYS_ID
			INNER JOIN dbo.SystemTypeTable ON RN_ID_TYPE = SST_ID
			INNER JOIN dbo.SystemNetCountTable ON RN_ID_NET = SNC_ID
			FOR XML PATH('')
		)

		IF @ERR IS NOT NULL
			RAISERROR(@ERR, 16, 2);

		IF EXISTS
			(
				SELECT *
				FROM dbo.PeriodRegTable
				WHERE REG_ID_PERIOD = @periodid
			)
			SELECT 1 AS RES
		ELSE
			SELECT 0 AS RES

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REG_NODE_MOVE_CHECK] TO rl_reg_node_history_w;
GO
