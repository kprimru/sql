USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DEBT_SELECT]
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
					FROM dbo.SaldoLastView b
					WHERE SL_REST < 0
						AND a.CL_ID = b.CL_ID
				)
			ORDER BY CL_PSEDO
		ELSE
			SELECT CL_ID, CL_PSEDO, CL_FULL_NAME, 0 AS CL_NAH,
				UNKNOWN_FINANCING
			FROM dbo.ClientTable a LEFT OUTER JOIN dbo.ClientFinancing ON CL_ID = ID_CLIENT
			WHERE EXISTS
				(
					SELECT *
					FROM dbo.SaldoLastView b
					WHERE SL_REST < 0
						AND a.CL_ID = b.CL_ID
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
GRANT EXECUTE ON [dbo].[CLIENT_DEBT_SELECT] TO rl_client_fin_r;
GO
