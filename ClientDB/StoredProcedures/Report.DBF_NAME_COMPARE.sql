﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[DBF_NAME_COMPARE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[DBF_NAME_COMPARE]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[DBF_NAME_COMPARE]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT
			CL_PSEDO AS [Псевдоним], TO_NAME AS [Название ТО], CL_SHORT_NAME AS [Короткое название клиента],
			(
				SELECT TOP 1 DIS_STR
				FROM [DBF].[dbo.ClientDistrView]
				WHERE CD_ID_CLIENT = CL_ID
					AND DSS_REPORT = 1
				ORDER BY SYS_ORDER
			) AS [Основной дистрибутив]
		FROM [DBF].[dbo.TOTable]
		INNER JOIN [DBF].[dbo.ClientTable] ON TO_ID_CLIENT = CL_ID
		WHERE TO_REPORT = 1
			AND LTRIM(RTRIM(TO_NAME)) NOT LIKE RTRIM(LTRIM(CL_SHORT_NAME)) + '%'
			--AND TO_NAME LIKE CL_SHORT_NAME + '%'
			AND EXISTS
				(
					SELECT *
					FROM [DBF].[dbo.ClientDistrView]
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
GO
GRANT EXECUTE ON [Report].[DBF_NAME_COMPARE] TO rl_report;
GO
