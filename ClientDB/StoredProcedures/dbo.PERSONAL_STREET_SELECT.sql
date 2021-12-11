USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PERSONAL_STREET_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PERSONAL_STREET_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PERSONAL_STREET_SELECT]
	@SERVICE	SMALLINT,
	@MANAGER	SMALLINT,
	@MY_CITY	BIT = 1
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
			ST_ID, ST_NAME + ISNULL(' ' + ISNULL(ST_PREFIX, ST_SUFFIX), '') +
			CASE CT_DISPLAY
				WHEN 1 THEN ', ' + CT_NAME
				ELSE ''
			END AS ST_STR
		FROM
			dbo.Street a
			INNER JOIN dbo.City b ON a.ST_ID_CITY = b.CT_ID
		WHERE (@MY_CITY = 0)
			OR (@MY_CITY = 1 AND EXISTS
				(
					SELECT *
					FROM dbo.PersonalCityView z
					WHERE z.CT_ID = b.CT_ID
						AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
						AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				)
				)
		ORDER BY ST_NAME, CT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
