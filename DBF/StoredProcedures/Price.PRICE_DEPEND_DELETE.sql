USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[PRICE_DEPEND_DELETE]
	@OLD_PRICE	SMALLINT,
	@OLD_SYS	SMALLINT,
	@OLD_NET	SMALLINT,
	@NEW_PRICE	SMALLINT,
	@NEW_SYS	SMALLINT,
	@NEW_NET	SMALLINT
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

		DELETE
		FROM Price.PriceDepend
		WHERE ID_OLD_PRICE = @OLD_PRICE
			AND ID_OLD_SYS_TYPE = @OLD_SYS
			AND ID_OLD_NET = @OLD_NET
			AND ID_NEW_PRICE = @NEW_PRICE
			AND ID_NEW_SYS_TYPE = @NEW_SYS
			AND ID_NEW_NET  = @NEW_NET
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
