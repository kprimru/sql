USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CITY_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT a.CT_ID, RG_NAME, AR_NAME, a.CT_NAME, b.CT_NAME AS CT_MASTER, a.CT_PREFIX, a.CT_SUFFIX, a.CT_DISPLAY, a.CT_DEFAULT
		FROM 
			dbo.City a
			LEFT OUTER JOIN dbo.City b ON a.CT_ID_CITY = b.CT_ID
			LEFT OUTER JOIN dbo.Region ON RG_ID = a.CT_ID_REGION
			LEFT OUTER JOIN dbo.Area ON AR_ID = a.CT_ID_AREA
		WHERE @FILTER IS NULL
			OR a.CT_NAME LIKE @FILTER
			OR b.CT_NAME LIKE @FILTER
			OR RG_NAME LIKE @FILTER
			OR AR_NAME LIKE @FILTER
			OR a.CT_PREFIX LIKE @FILTER
		ORDER BY a.CT_NAME, RG_NAME, AR_NAME
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END