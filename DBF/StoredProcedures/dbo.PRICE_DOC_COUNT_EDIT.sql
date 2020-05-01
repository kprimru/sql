USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Изменить данные о количестве
               документов для указанной системы
               на указанную дату
*/

ALTER PROCEDURE [dbo].[PRICE_DOC_COUNT_EDIT]
	@systemid SMALLINT,
	@periodid SMALLINT,
	@doccount INT
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

		IF EXISTS (
					SELECT *
					FROM dbo.PriceSystemHistoryTable
					WHERE PSH_ID_SYSTEM = @systemid AND
						PSH_ID_PERIOD = @periodid
					)
		BEGIN
			UPDATE dbo.PriceSystemHistoryTable
			SET PSH_DOC_COUNT = @doccount
			WHERE PSH_ID_SYSTEM = @systemid AND
				PSH_ID_PERIOD = @periodid
		END
		ELSE
		BEGIN
			INSERT INTO dbo.PriceSystemHistoryTable (PSH_ID_PERIOD, PSH_ID_SYSTEM, PSH_DOC_COUNT)
			VALUES (@periodid, @systemid, @doccount)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[PRICE_DOC_COUNT_EDIT] TO rl_price_list_w;
GO