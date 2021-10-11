USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 05.11.2008
Описание:	  Изменить данные о сбытовой
               территории с указанным кодом
*/

ALTER PROCEDURE [dbo].[MARKET_AREA_EDIT]
	@marketareaid INT,
	@marketareaname VARCHAR(100),
	@marketareashortname VARCHAR(50),
	@active BIT = 1
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

		UPDATE dbo.MarketAreaTable
		SET MA_NAME = @marketareaname,
			MA_SHORT_NAME = @marketareashortname,
			MA_ACTIVE = @active
		WHERE MA_ID = @marketareaid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[MARKET_AREA_EDIT] TO rl_market_area_w;
GO
