USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MANAGER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[MANAGER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[MANAGER_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Serviced Table
	(
		[Id] SmallInt NOT NULL PRIMARY KEY CLUSTERED
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Serviced
		SELECT ServiceStatusId
		FROM [dbo].[ServiceStatusConnected]();

		SELECT
			ManagerID, ManagerName, ManagerLogin, ManagerCount,
			CONVERT(BIT, CASE WHEN ManagerCount <> 0 AND ManagerName <> 'Исаева' THEN 1 ELSE 0 END) AS ManagerCheck,
			CASE WHEN  ManagerCount = 0 THEN 1 ELSE 0 END AS ManagerEnable, ManagerLocal
		FROM dbo.ManagerTable AS M
		OUTER APPLY
		(
			SELECT TOP (1)
				[ManagerCount] = Count(*)
			FROM dbo.ClientView AS C WITH(NOEXPAND)
			INNER JOIN @Serviced AS SS ON C.ServiceStatusId = SS.Id
			WHERE C.ManagerID = M.ManagerID
		) AS S
		WHERE @FILTER IS NULL
			OR ManagerName LIKE @FILTER
			OR ManagerFullName LIKE @FILTER
			OR ManagerLogin LIKE @FILTER
		ORDER BY ManagerName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[MANAGER_SELECT] TO rl_personal_manager_r;
GO
