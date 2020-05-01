USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей
Дата создания:	3 July 2009
Описание:		Возвращает 0, если тип адреса в фин. документе
				с указанным кодом можно удалить из
				справочника,
				-1 в противном случае
*/

ALTER PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_DELETE]
	@fatid SMALLINT
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

		DELETE FROM dbo.FinancingAddressTypeTable
		WHERE FAT_ID = @fatid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[FINANCING_ADDRESS_TYPE_DELETE] TO rl_financing_address_type_d;
GO