USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Дата создания:	3 July 2009
Описание:

*/

ALTER PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_EDIT]
	@fatid SMALLINT,
	@addrtypeid TINYINT,
	@text VARCHAR(50),
	@active BIT
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

		UPDATE dbo.FinancingAddressTypeTable
		SET	FAT_ID_ADDR_TYPE = @addrtypeid,
			FAT_TEXT = @text,
			FAT_ACTIVE = @active

		WHERE FAT_ID = @fatid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[FINANCING_ADDRESS_TYPE_EDIT] TO rl_financing_address_type_w;
GO