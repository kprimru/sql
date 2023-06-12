USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_TYPE_TRY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_TYPE_TRY_DELETE]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Возвращает 0, если тип прейскуранта
               можно удалить из справочника,
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[PRICE_TYPE_TRY_DELETE]
	@pricetypeid SMALLINT
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
		IF EXISTS(SELECT * FROM dbo.PriceTable WHERE PP_ID_TYPE = @pricetypeid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Невозможно удалить тип прейскуранта, так как имеются прейскуранты этого типа.'
			END

		-- связь PriceType <-> PriceSystem <-> System

		IF EXISTS(SELECT * FROM dbo.PriceSystemTable WHERE PS_ID_TYPE = @pricetypeid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Невозможно удалить тип прейскуранта, так как существует' +
								+ 'запись о стоимости систем по этому типу прейскуранта.' + CHAR(13)
			END

		--

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
GRANT EXECUTE ON [dbo].[PRICE_TYPE_TRY_DELETE] TO rl_price_type_d;
GO
