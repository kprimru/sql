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

ALTER PROCEDURE [dbo].[AUDIT_VMI_SELECT]
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

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

		CREATE TABLE #temp
			(
				TOID INT,
				TO_COMMENT VARCHAR(500)
			)

		INSERT INTO #temp
			SELECT TO_ID, 'Установлены только дополнительные системы'
			FROM 
				dbo.TOTable
			WHERE EXISTS
					(
						SELECT *
						FROM
							dbo.DistrView WITH(NOEXPAND) INNER JOIN
							dbo.TODistrTable ON TD_ID_DISTR = DIS_ID LEFT OUTER JOIN
							dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
									AND RN_DISTR_NUM = DIS_NUM
									AND RN_COMP_NUM = DIS_COMP_NUM
						WHERE TD_ID_TO = TO_ID AND
							DIS_ACTIVE = 1 AND SYS_REG_NAME <> '-'
							AND RN_SERVICE <> 2
					) AND
				NOT EXISTS
					(
						SELECT *
						FROM dbo.DistrView WITH(NOEXPAND) INNER JOIN
							dbo.TODistrTable ON TD_ID_DISTR = DIS_ID LEFT OUTER JOIN
							dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
									AND RN_DISTR_NUM = DIS_NUM
									AND RN_COMP_NUM = DIS_COMP_NUM
						WHERE TD_ID_TO = TO_ID AND
							DIS_ACTIVE = 1 AND
							SYS_REPORT = 1 AND SYS_REG_NAME <> '-'
							AND RN_SERVICE <> 2
					) AND TO_REPORT = 1


		INSERT INTO #temp
			SELECT TO_ID, 'Дистрибутив передан другому клиенту'
			FROM dbo.TOTable
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						dbo.TODistrTable INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR LEFT OUTER JOIN
						dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
									AND RN_DISTR_NUM = DIS_NUM
									AND RN_COMP_NUM = DIS_COMP_NUM
					WHERE DIS_ACTIVE = 1 AND TD_ID_TO = TO_ID AND SYS_REG_NAME <> '-'
						AND RN_SERVICE <> 2
				) AND TO_REPORT = 1

		INSERT INTO #temp
			SELECT TO_ID, ''
			FROM dbo.TOTable
			WHERE EXISTS
				(
					SELECT *
					FROM
						dbo.TODistrTable INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR
					WHERE DIS_ACTIVE = 1 AND TD_ID_TO = TO_ID AND SYS_REG_NAME <> '-'
						AND SYS_REPORT = 1
				) AND TO_REPORT = 1

		SELECT
			CL_ID, CL_FULL_NAME,
			TO_ID, TO_NUM, TO_VMI_COMMENT,
			TO_COMMENT AS TO_ERROR
		FROM
			dbo.TOTable INNER JOIN
			dbo.ClientTable ON CL_ID = TO_ID_CLIENT INNER JOIN
			#temp ON TOID = TO_ID
		WHERE TO_VMI_COMMENT <> TO_COMMENT

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[AUDIT_VMI_SELECT] TO rl_audit_vmi;
GO