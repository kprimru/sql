USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[STREET_GET]
	@streetid INT = NULL
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

		SELECT ST_NAME, ST_PREFIX, ST_SUFFIX, ST_ID, CT_ID, CT_NAME, ST_ACTIVE
		FROM
			dbo.StreetTable st LEFT OUTER JOIN
			dbo.CityTable ct ON ct.CT_ID = st.ST_ID_CITY
		WHERE ST_ID = @streetid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STREET_GET] TO rl_street_r;
GO
