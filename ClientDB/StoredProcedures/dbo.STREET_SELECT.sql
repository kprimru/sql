USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STREET_SELECT]
	@FILTER		VARCHAR(250) = NULL,
	@MY			BIT = 1,
	@SERVICE	INT = NULL
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

		DECLARE @MANAGER	INT

		SELECT @MANAGER = ManagerID
		FROM dbo.ManagerTable
		WHERE ManagerLogin = ORIGINAL_LOGIN()

		IF @SERVICE IS NOT NULL
			SELECT @SERVICE = ServiceID
			FROM dbo.ServiceTable
			WHERE ServiceLogin = ORIGINAL_LOGIN()

		DECLARE @CITY TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO @CITY(ID)
			SELECT CT_ID
			FROM dbo.PersonalCityView WITH(NOEXPAND)
			WHERE ManagerID = @MANAGER
				OR ServiceID = @SERVICE

		IF NOT EXISTS(SELECT * FROM @CITY)
			INSERT INTO @CITY(ID)
				SELECT CT_ID
				FROM dbo.City
				WHERE CT_DEFAULT = 1

		IF OBJECT_ID('tempdb..#search') IS NOT NULL
			DROP TABLE #search

		CREATE TABLE #search
			(
				WRD		VARCHAR(250) PRIMARY KEY
			)

		IF @FILTER IS NOT NULL
			INSERT INTO #search(WRD)
				SELECT DISTINCT '%' + Word + '%'
				FROM dbo.SplitString(@FILTER)


		SELECT ST_ID, CT_NAME, ST_NAME, ST_PREFIX, ST_SUFFIX, ST_STR, ST_LOOKUP
		FROM
			dbo.StreetView
		WHERE (@FILTER IS NULL
			OR
			NOT EXISTS
				(
					SELECT *
					FROM #search
					WHERE NOT (ST_LOOKUP LIKE WRD)
				)
			)
			AND
			(
				@MY = 0 OR
				EXISTS
					(
						SELECT *
						FROM @CITY
						WHERE ID = CT_ID
					)
			)
		ORDER BY ST_NAME, CT_NAME

		IF OBJECT_ID('tempdb..#search') IS NOT NULL
			DROP TABLE #search

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[STREET_SELECT] TO rl_street_r;
GO