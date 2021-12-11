USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_LIST_PREPARE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_LIST_PREPARE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_LIST_PREPARE]
	@SERVICE	NVARCHAR(MAX),
	@MANAGER	NVARCHAR(MAX)
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

		SELECT ServiceID, ServiceName
		FROM
			(
				SELECT ID
				FROM dbo.TableIDFromXML(@SERVICE)

				UNION

				SELECT ServiceID
				FROM
					dbo.TableIDFromXML(@MANAGER)
					INNER JOIN dbo.ServiceTable ON ManagerID = ID
			) AS a
			INNER JOIN dbo.ServiceTable b ON b.ServiceID = a.ID
		ORDER BY ServiceName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_LIST_PREPARE] TO public;
GO
