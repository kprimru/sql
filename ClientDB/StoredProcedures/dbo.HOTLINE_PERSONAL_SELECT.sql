USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[HOTLINE_PERSONAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[HOTLINE_PERSONAL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[HOTLINE_PERSONAL_SELECT]
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

		SELECT DISTINCT Item AS PERSONAL
		FROM
			(
				SELECT DISTINCT RIC_PERSONAL
				FROM dbo.HotlineChat
			) AS a
			CROSS APPLY
			(
				SELECT Item
				FROM dbo.GET_STRING_TABLE_FROM_LIST(RIC_PERSONAL, ',')
			) AS b
		ORDER BY PERSONAL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[HOTLINE_PERSONAL_SELECT] TO rl_hotline_filter;
GO
