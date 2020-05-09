USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 21.11.2008
Описание:	  Выбрать все системы, которые
               не присутствуют в прейскуранте
               указанного типа на указанный
               период
*/

ALTER PROCEDURE [dbo].[PRICE_SYSTEM_LIST_GET]
	@pricetypeid SMALLINT,
	@periodid SMALLINT
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

		SELECT 'Система' AS IS_SYS, SYS_ID, SYS_SHORT_NAME, HST_NAME
		FROM dbo.SystemTable a LEFT OUTER JOIN
			 dbo.HostTable d ON a.SYS_ID_HOST = d.HST_ID
		WHERE SYS_ID NOT IN
			 (
			   SELECT SYS_ID
			   FROM dbo.SystemTable c INNER JOIN
					dbo.PriceSystemTable b ON b.PS_ID_SYSTEM = c.SYS_ID
			   WHERE PS_ID_TYPE = @pricetypeid AND
					 PS_ID_PERIOD = @periodid AND
					 c.SYS_ID = a.SYS_ID
			 ) AND SYS_ACTIVE = 1

		UNION

		SELECT 'Доп.услуга' AS IS_SYS, PGD_ID, PGD_NAME, '-'
		FROM dbo.PriceGoodTable
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.PriceSystemTable
				WHERE PS_ID_TYPE = @pricetypeid
					AND PS_ID_PERIOD = @periodid
					AND PS_ID_PGD = PGD_ID
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_LIST_GET] TO rl_price_val_w;
GO