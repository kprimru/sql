USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Возвращает 0, если прейскурант
               можно удалить из справочника,
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[PRICE_TRY_DELETE]
	@priceid SMALLINT
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

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''

		-- добавлено 29.04.2009, В.Богдан
		-- убрано 15.06.2009, А.Денисов. Причина: схемы вообще в печь
		/*
		IF EXISTS(SELECT * FROM SchemaTable WHERE SCH_ID_PRICE = @priceid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Невозможно удалить прейскурант, так как имеются схемы с этим прейскурантом.'
			END
		--
		*/

		SELECT @res AS RES, @txt AS TXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_TRY_DELETE] TO rl_price_d;
GO