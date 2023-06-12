USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PRICE_GROUP_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PRICE_GROUP_EDIT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Изменить данные о типе прейскуранта
               с указанным кодом
*/

ALTER PROCEDURE [dbo].[PRICE_GROUP_EDIT]
	@id SMALLINT,
	@name VARCHAR(50),
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

		UPDATE dbo.PriceGroupTable
		SET PG_NAME = @name,
			PG_ACTIVE = @active
		WHERE PG_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_GROUP_EDIT] TO rl_price_group_w;
GO
