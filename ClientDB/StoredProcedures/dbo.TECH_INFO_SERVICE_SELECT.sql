USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TECH_INFO_SERVICE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TECH_INFO_SERVICE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[TECH_INFO_SERVICE_SELECT]
	@MANAGER INT,
	@SERVICE INT
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
			b.ManagerID, ManagerName, ServiceID, ServiceName,
			ServiceFullName, ServicePhone,
			(
				SELECT COUNT(*)
				FROM dbo.ClientTable
				WHERE ClientServiceID = ServiceID
					AND STATUS = 1
			) AS ServiceCount
		FROM
			dbo.ServiceTable a INNER JOIN
    		dbo.ManagerTable b ON a.ManagerID = b.ManagerID
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (b.ManagerID = @MANAGER OR @MANAGER IS NULL)
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
GRANT EXECUTE ON [dbo].[TECH_INFO_SERVICE_SELECT] TO rl_tech_info;
GO
