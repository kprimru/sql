USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTROL_DOCUMENT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTROL_DOCUMENT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTROL_DOCUMENT_SELECT]
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
			a.DATE, a.RIC,
			ISNULL((
				SELECT TOP 1 e.InfoBankShortName
				FROM dbo.InfoBankTable e
				WHERE e.InfoBankName = a.IB
			), a.IB) AS InfoBankShortName, IB_NUM, DOC_NAME
		FROM
			dbo.ControlDocument a
			INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
			INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DISTR AND a.COMP = c.COMP

		WHERE ID_CLIENT = @CLIENT
		ORDER BY a.DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTROL_DOCUMENT_SELECT] TO rl_client_control_document;
GO
