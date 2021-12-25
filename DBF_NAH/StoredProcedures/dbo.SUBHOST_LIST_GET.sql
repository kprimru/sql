USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_LIST_GET]
	@SH_ID VARCHAR(MAX)
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

		IF @SH_ID IS NULL
			SELECT SH_ID, SH_SHORT_NAME
			FROM dbo.SubhostTable
			WHERE SH_ID = 11
			ORDER BY SH_ORDER
		ELSE
			SELECT SH_ID, SH_SHORT_NAME
			FROM
				dbo.SubhostTable INNER JOIN
				dbo.GET_TABLE_FROM_LIST(@SH_ID, ',') ON Item = SH_ID
			ORDER BY SH_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_LIST_GET] TO rl_subhost_calc;
GO
