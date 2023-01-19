USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[COURIER_SELECT_BY_TYPE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[COURIER_SELECT_BY_TYPE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[COURIER_SELECT_BY_TYPE]
	@TYPE	SMALLINT
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

		SELECT COUR_ID, COUR_NAME
		FROM dbo.CourierTable
		WHERE COUR_ID_TYPE = @TYPE AND COUR_ACTIVE = 1
		ORDER BY COUR_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[COURIER_SELECT_BY_TYPE] TO rl_courier_r;
GO
