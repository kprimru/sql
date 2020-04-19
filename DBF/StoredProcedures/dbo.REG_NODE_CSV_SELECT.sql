USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[REG_NODE_CSV_SELECT]
	@SH	VARCHAR(MAX)
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

		DECLARE @SH_SHORT VARCHAR(50)

		SELECT TOP 1 @SH_SHORT = SH_LST_NAME
		FROM 
			dbo.SubhostTable INNER JOIN
			dbo.GET_TABLE_FROM_LIST(@SH, ',') ON SH_ID = Item
		
		SELECT *
		FROM dbo.RegNodeTable
		WHERE RN_COMMENT LIKE '(' + @SH_SHORT + ')%'
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
