USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[DBF_NAME_COMPARE]
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
			CL_PSEDO AS [���������], TO_NAME AS [�������� ��], CL_SHORT_NAME AS [�������� �������� �������],
			(
				SELECT TOP 1 DIS_STR
				FROM [PC275-SQL\DELTA].DBF.dbo.ClientDistrView
				WHERE CD_ID_CLIENT = CL_ID
					AND DSS_REPORT = 1
				ORDER BY SYS_ORDER
			) AS [�������� �����������]
		FROM
			[PC275-SQL\DELTA].DBF.dbo.TOTable
			INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ClientTable ON TO_ID_CLIENT = CL_ID
		WHERE TO_REPORT = 1
			AND LTRIM(RTRIM(TO_NAME)) NOT LIKE RTRIM(LTRIM(CL_SHORT_NAME)) + '%'
			--AND TO_NAME LIKE CL_SHORT_NAME + '%'
			AND EXISTS
				(
					SELECT *
					FROM [PC275-SQL\DELTA].DBF.dbo.ClientDistrView
					WHERE CD_ID_CLIENT = CL_ID
						AND DSS_REPORT = 1
				)
		ORDER BY CL_PSEDO

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[DBF_NAME_COMPARE] TO rl_report;
GO