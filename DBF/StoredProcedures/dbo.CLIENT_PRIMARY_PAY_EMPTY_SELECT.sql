USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_PRIMARY_PAY_EMPTY_SELECT]
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

		SELECT CL_ID, CL_PSEDO, CL_FULL_NAME
		FROM dbo.ClientTable
		WHERE EXISTS
			(
				SELECT *
				FROM
					dbo.ClientDistrTable LEFT OUTER JOIN
					dbo.PrimaryPayTable ON PRP_ID_DISTR = CD_ID_DISTR
				WHERE CD_ID_CLIENT = CL_ID AND PRP_ID IS NULL
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
GRANT EXECUTE ON [dbo].[CLIENT_PRIMARY_PAY_EMPTY_SELECT] TO rl_client_fin_r;
GO