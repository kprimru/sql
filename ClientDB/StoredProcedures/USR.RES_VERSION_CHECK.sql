USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[RES_VERSION_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[RES_VERSION_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[RES_VERSION_CHECK]
	@MANAGER	INT,
	@SERVICE	INT,
	@DATE		SMALLDATETIME,
	@STATUS		VARCHAR(MAX),
	@ACTUAL		BIT,
	@CUSTOM		BIT,
	@RLIST		VARCHAR(MAX),
	@CLIST		VARCHAR(MAX),
	@KLIST		VARCHAR(MAX) = NULL
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
			[ClientID],
			[ClientFullName],
			[ManagerName],
			[ServiceName],
			[Complect],
			[ResVersionNumber],
			[ConsExeVersionName],
			[KDVersionName],
			[UF_DATE],
			[UF_CREATE]
		FROM [Usr].[ResVersion@Check]
		(
			@MANAGER,
			@SERVICE,
			@DATE,
			@STATUS,
			@ACTUAL,
			@CUSTOM,
			@RLIST,
			@CLIST,
			@KLIST
		)
		ORDER BY [ManagerName], [ServiceName], [ClientFullName], [Complect];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
