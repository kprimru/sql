USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SELECT_SERVICE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SELECT_SERVICE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SELECT_SERVICE]
	@managerid	INT,
	@ACTIVE		BIT = 0
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

		SELECT ServiceName, ServicePositionName, ServiceCount
		FROM
			(
				SELECT
					ServiceName, ServicePositionName,
					(
						SELECT COUNT(ClientID)
						FROM dbo.ClientTable z
						INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.StatusId = s.ServiceStatusId
						WHERE z.STATUS = 1 AND z.ClientServiceID = a.ServiceID
					) AS ServiceCount
				FROM
					dbo.ServiceTable a
					LEFT OUTER JOIN	dbo.ServicePositionTable b ON a.ServicePositionID = b.ServicePositionID
				WHERE ManagerID = @managerid
			) AS o_O
		WHERE (@ACTIVE = 0 OR ServiceCount <> 0)
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
GRANT EXECUTE ON [dbo].[SELECT_SERVICE] TO rl_personal_manager_r;
GO
