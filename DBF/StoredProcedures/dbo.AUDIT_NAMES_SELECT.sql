USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AUDIT_NAMES_SELECT]
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

		SELECT CL_ID, TO_ID, CL_PSEDO, TO_NAME, CL_SHORT_NAME,
			(
				SELECT TOP 1 DIS_STR
				FROM dbo.ClientDistrView
				WHERE CD_ID_CLIENT = CL_ID
					AND DSS_REPORT = 1
				ORDER BY SYS_ORDER
			) AS DIS_STR
		FROM dbo.TOTable
		INNER JOIN dbo.ClientTable ON TO_ID_CLIENT = CL_ID
		WHERE TO_REPORT = 1
			AND TO_NAME NOT LIKE CL_SHORT_NAME + '%'
			--AND TO_NAME LIKE CL_SHORT_NAME + '%'
			AND EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView
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
