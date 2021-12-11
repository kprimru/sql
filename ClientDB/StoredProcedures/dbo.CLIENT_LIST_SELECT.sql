USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_LIST_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_LIST_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_LIST_SELECT]
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

		DECLARE @Client Table
		(
			CL_ID INT PRIMARY KEY CLUSTERED
		);

		DECLARE @RClient Table
		(
			RCL_ID INT PRIMARY KEY CLUSTERED
		);

		DECLARE @WClient Table
		(
			WCL_ID INT PRIMARY KEY CLUSTERED
		);

		INSERT INTO @RClient
		SELECT WCL_ID
		FROM [dbo].[ClientList@Get?Read]()

		INSERT INTO @WClient
		SELECT WCL_ID
		FROM [dbo].[ClientList@Get?Write]()

		INSERT INTO @Client(CL_ID)
		SELECT RCL_ID
		FROM @RClient


		SELECT
			ClientID = CL_ID,
			CASE
				WHEN WCL_ID IS NULL THEN CONVERT(BIT, 0)
				ELSE CONVERT(BIT, 1)
			END AS ClientEdit
		FROM @Client
		LEFT MERGE JOIN @WClient ON CL_ID = WCL_ID
		ORDER BY CL_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_LIST_SELECT] TO rl_client_list;
GO
