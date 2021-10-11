USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_GET]
	@personalid INT
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
				PER_ID, PER_FAM, PER_NAME, PER_OTCH,
				(PER_FAM + ' ' + PER_NAME + ' ' + PER_OTCH) AS PER_FULL_NAME,
				POS_NAME, POS_ID, RP_ID, RP_NAME	--, PER_PHONE
		FROM
				dbo.ClientPersonalTable	cp												LEFT OUTER JOIN
				dbo.PositionTable		pt	ON cp.PER_ID_POS = pt.POS_ID				LEFT OUTER JOIN
				dbo.ReportPositionTable	prt	ON prt.RP_ID = cp.PER_ID_REPORT_POS
		WHERE
				PER_ID = @personalid
		ORDER BY
				PER_FAM, PER_NAME, PER_OTCH, POS_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_GET] TO rl_client_personal_r;
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_GET] TO rl_client_r;
GO
