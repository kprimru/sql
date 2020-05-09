USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SYSTEM_HISTORY]
	@ID	INT
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

		SELECT IDMaster AS ID, SystemBegin, NULL AS SystemEnd, SystemOp
		FROM
			(
				SELECT SystemBegin AS SystemOp
				FROM dbo.ClientSystemDatesTable
				WHERE IDMaster = @id

				UNION

				SELECT SystemEnd
				FROM dbo.ClientSystemDatesTable
				WHERE IDMaster = @id
			) AS a INNER JOIN
			dbo.ClientSystemDatesTable b ON a.SystemOp = b.SystemBegin
		WHERE IDMaster = @id

		UNION

		SELECT IDMaster AS ID, NULL AS SystemBegin, SystemEnd, SystemOp
		FROM
			(
				SELECT SystemBegin AS SystemOp
				FROM dbo.ClientSystemDatesTable
				WHERE IDMaster = @id

				UNION

				SELECT SystemEnd
				FROM dbo.ClientSystemDatesTable
				WHERE IDMaster = @id
			) AS a INNER JOIN
			dbo.ClientSystemDatesTable b ON a.SystemOp = b.SystemEnd
		WHERE IDMaster = @id
		ORDER BY SystemOp DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SYSTEM_HISTORY] TO rl_client_system_history;
GO