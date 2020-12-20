USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[DZ_ACTION_CHECK]
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
			CL_PSEDO AS [���������], CL_FULL_NAME AS [������],
			(
				SELECT
					dbo.DistrString(SYS_SHORT_NAME, DIS_NUM, DIS_COMP_NUM) + ' (' +
					-- ToDo - ������� ����� ����������
					CASE RN_TECH_TYPE
						WHEN 0 THEN
							CASE RN_NET_COUNT
								WHEN 0 THEN '���'
								WHEN 1 THEN '1/�'
								WHEN 5 THEN '�/�'
								ELSE '����'
							END
						WHEN 1 THEN '����'
						WHEN 7 THEN '���'
						WHEN 3 THEN '���'
						WHEN 6 THEN '����'
						WHEN 9 THEN '���'
						WHEN 10 THEN '���-�'
						ELSE '����������'
					END
					 + '), '
				FROM
					[PC275-SQL\DELTA].DBF.dbo.ClientDistrView a
					INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeView b ON a.SYS_REG_NAME = b.RN_SYS_NAME AND a.DIS_NUM = b.RN_DISTR_NUM AND a.DIS_COMP_NUM = b.RN_COMP_NUM
				WHERE a.CD_ID_CLIENT = z.CL_ID AND b.RN_SERVICE = 0
				ORDER BY RN_TECH_TYPE, SYS_ORDER, DIS_NUM FOR XML PATH('')
			) AS [������������],
			(
				SELECT COUR_NAME
				FROM [PC275-SQL\DELTA].DBF.dbo.ClientCourVIew t
				WHERE t.CL_ID = z.CL_ID
			) AS [��]
		FROM [PC275-SQL\DELTA].DBF.dbo.ClientTable z
		WHERE EXISTS
			(
				SELECT *
				FROM
					[PC275-SQL\DELTA].DBF.dbo.ClientDistrView a
					INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeTable b ON a.SYS_REG_NAME = b.RN_SYS_NAME AND a.DIS_NUM = b.RN_DISTR_NUM AND a.DIS_COMP_NUM = b.RN_COMP_NUM
				WHERE a.CD_ID_CLIENT = z.CL_ID AND b.RN_SERVICE = 0
					AND b.RN_TECH_TYPE IN (1, 7)
			)
			AND EXISTS
			(
				SELECT *
				FROM
					[PC275-SQL\DELTA].DBF.dbo.ClientDistrView a
					INNER JOIN [PC275-SQL\DELTA].DBF.dbo.RegNodeTable b ON a.SYS_REG_NAME = b.RN_SYS_NAME AND a.DIS_NUM = b.RN_DISTR_NUM AND a.DIS_COMP_NUM = b.RN_COMP_NUM
				WHERE a.CD_ID_CLIENT = z.CL_ID AND b.RN_SERVICE = 0
					AND b.RN_DISTR_TYPE = 'UZ2'
			)
			--AND CL_ID_ORG = 1
		ORDER BY 4, 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[DZ_ACTION_CHECK] TO rl_report;
GO