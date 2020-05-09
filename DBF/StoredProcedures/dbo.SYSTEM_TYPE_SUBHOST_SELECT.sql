USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_TYPE_SUBHOST_SELECT]
	@SH_ID	SMALLINT
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
			a.SST_ID, a.SST_CAPTION, CONVERT(BIT, 0) AS SST_CHECKED,
			b.SST_ID AS SST_HOST_ID, b.SST_CAPTION AS SST_HOST_CAPTION,
			c.SST_ID AS SST_DHOST_ID, c.SST_CAPTION AS SST_DHOST_CAPTION
		FROM
			dbo.SystemTypeTable a
			LEFT OUTER JOIN dbo.SystemTypeTable b ON b.SST_ID = a.SST_ID_HOST
			LEFT OUTER JOIN dbo.SystemTypeTable c ON c.SST_ID = a.SST_ID_DHOST
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemTypeSubhost
				WHERE STS_ID_TYPE = a.SST_ID
					AND STS_ID_SUBHOST = @SH_ID
			)

		UNION ALL

		SELECT
			b.SST_ID, b.SST_CAPTION, CONVERT(BIT, 1) AS SST_CHECKED,
			c.SST_ID AS SST_HOST_ID, c.SST_CAPTION AS SST_HOST_CAPTION,
			d.SST_ID AS SST_DHOST_ID, d.SST_CAPTION AS SST_DHOST_CAPTION
		FROM
			dbo.SystemTypeSubhost a
			INNER JOIN dbo.SystemTypeTable b ON a.STS_ID_TYPE = b.SST_ID
			LEFT OUTER JOIN dbo.SystemTypeTable c ON c.SST_ID = a.STS_ID_HOST
			LEFT OUTER JOIN dbo.SystemTypeTable d ON d.SST_ID = a.STS_ID_DHOST
		WHERE STS_ID_SUBHOST = @SH_ID
		ORDER BY SST_CAPTION

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_SUBHOST_SELECT] TO rl_subhost_r;
GO