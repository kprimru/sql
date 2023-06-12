USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_SYSTEM_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_SYSTEM_ADD]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Добавить указанную систему
               в указанный прейскурант на
               указанный период с указанной
               стоимостью
*/

ALTER PROCEDURE [dbo].[PRICE_SYSTEM_ADD]
	@pricetypeid SMALLINT,
	@periodid SMALLINT,
	@systemid SMALLINT,
	@price MONEY,
	@pgdid SMALLINT,
	@returnvalue BIT = 1
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

		IF @pgdid IS NOT NULL
			INSERT INTO dbo.PriceSystemTable(PS_ID_PERIOD, PS_ID_TYPE, PS_ID_PGD, PS_PRICE)
			VALUES (@periodid, @pricetypeid, @pgdid, @price)
		ELSE
			INSERT INTO dbo.PriceSystemTable(PS_ID_PERIOD, PS_ID_TYPE, PS_ID_SYSTEM, PS_PRICE)
			VALUES (@periodid, @pricetypeid, @systemid, @price)

		IF @returnvalue = 1
		  SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_ADD] TO rl_price_list_w;
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_ADD] TO rl_price_val_w;
GO
