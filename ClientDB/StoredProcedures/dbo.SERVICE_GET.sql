USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_GET]
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

		SELECT
			ServiceName, ServicePositionID, ManagerID, ServicePhone, ServiceLogin, ServiceFullName,
			('<LIST>' +
				(
					SELECT '{' + CONVERT(VARCHAR(50), ID_CITY) + '}' AS ITEM
					FROM dbo.ServiceCity
					WHERE ID_SERVICE = ServiceID
					ORDER BY ID_CITY FOR XML PATH('')
				)
			+ '</LIST>') AS CT_LIST
		FROM
			dbo.ServiceTable
		WHERE ServiceID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_GET] TO rl_personal_service_r;
GO
