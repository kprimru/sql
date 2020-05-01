USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[STREET_SELECT]  
    @active BIT = NULL
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

		SELECT ST_NAME, ST_PREFIX, ST_ID, CT_ID, CT_NAME, ISNULL(CT_NAME, '') + ', ' + ISNULL(ST_NAME, '') AS ST_CITY_NAME
		FROM 
			dbo.StreetTable st LEFT OUTER JOIN
			dbo.CityTable ct ON ct.CT_ID = st.ST_ID_CITY
		WHERE ST_ACTIVE = ISNULL(@active, ST_ACTIVE)
		ORDER BY ST_NAME, CT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
