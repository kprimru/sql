USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_INNOVATION_SELECT]
	@CLIENT	INT
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
			a.ID, b.NAME, c.ID AS ID_PERSONAL,
			c.DATE, c.SURNAME + ' ' + c.NAME + ' ' + c.PATRON + ' (' + c.POSITION + ')' AS FIO, c.NOTE,
			c.SURNAME AS PER_SURNAME, c.NAME AS PER_NAME, c.PATRON AS PER_PATRON,
			d.DATE AS AUDIT_DATE, d.AUDITOR, d.SURNAME + ' ' + d.NAME + ' ' + d.PATRON AS AUDIT_FIO, d.NOTE AS AUDIT_NOTE,
			d.RESULT, CASE d.RESULT WHEN 1 THEN 'Подтверждено' WHEN 2 THEN 'Не подтверждено' ELSE '' END AS RESULT_STR
		FROM
			dbo.ClientInnovation a
			INNER JOIN dbo.Innovation b ON a.ID_INNOVATION = b.ID
			LEFT OUTER JOIN dbo.ClientInnovationPersonal c ON c.ID_INNOVATION = a.ID
			LEFT OUTER JOIN dbo.ClientInnovationControl d ON d.ID_PERSONAL = c.ID
		WHERE ID_CLIENT = @CLIENT
		ORDER BY b.START DESC, b.NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_INNOVATION_SELECT] TO rl_client_innovation_r;
GO