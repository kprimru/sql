USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTRICT_SELECT]
	@FILTER	VARCHAR(100) = NULL,
	@MY		BIT = 1
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
		DECLARE @SERVICE	INT
		
		SELECT @MANAGER = ManagerID
		FROM dbo.ManagerTable
		WHERE ManagerLogin = ORIGINAL_LOGIN()
		
		SELECT @MANAGER = ServiceID
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

		SELECT DS_ID, CT_NAME, DS_NAME
		FROM 
			dbo.District
			INNER JOIN dbo.City ON DS_ID_CITY = CT_ID
		WHERE (@FILTER IS NULL
			OR DS_NAME LIKE @FILTER
			OR CT_NAME LIKE @FILTER)
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
		ORDER BY DS_NAME, CT_NAME
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END