USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[MARKET_AREA_SELECT]
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

		SELECT MA_ID, MA_NAME, MA_SHORT_NAME
		FROM dbo.MarketAreaTable
		WHERE MA_ACTIVE = ISNULL(@active, MA_ACTIVE)
		ORDER BY MA_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[MARKET_AREA_SELECT] TO rl_market_area_r;
GO
