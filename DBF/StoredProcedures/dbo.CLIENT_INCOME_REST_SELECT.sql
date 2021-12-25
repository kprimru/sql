﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_INCOME_REST_SELECT]
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
			SELECT CL_ID, CL_PSEDO, CL_FULL_NAME, (SELECT COUNT(*) FROM DBF_NAH.dbo.ClientTable z WHERE z.CL_NUM = a.CL_NUM) AS CL_NAH,
				UNKNOWN_FINANCING
			FROM dbo.ClientTable a LEFT OUTER JOIN dbo.ClientFinancing ON CL_ID = ID_CLIENT
			WHERE EXISTS
				(
					SELECT *
					FROM dbo.IncomeView
					WHERE IN_ID_CLIENT = CL_ID AND IN_REST <> 0
				)
			ORDER BY CL_PSEDO
		ELSE
			SELECT CL_ID, CL_PSEDO, CL_FULL_NAME, 0 AS CL_NAH,
				UNKNOWN_FINANCING
			FROM dbo.ClientTable LEFT OUTER JOIN dbo.ClientFinancing ON CL_ID = ID_CLIENT
			WHERE EXISTS
				(
					SELECT *
					FROM dbo.IncomeView
					WHERE IN_ID_CLIENT = CL_ID AND IN_REST <> 0
				)
			ORDER BY CL_PSEDO, CL_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_INCOME_REST_SELECT] TO rl_income_r;
GO
