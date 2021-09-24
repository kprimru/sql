USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SELECT_EMPTY_CLIENT]
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

		SELECT ClientID, ClientFullName, ClientFullName AS ClientShortName, ServiceStatusName
		FROM
			dbo.ClientTable a INNER JOIN
			dbo.ServiceStatusTable b ON b.ServiceStatusID = a.StatusID
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientSystemsTable b
				WHERE a.ClientID = b.ClientID
			)
		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SELECT_EMPTY_CLIENT] TO rl_empty_client;
GO
