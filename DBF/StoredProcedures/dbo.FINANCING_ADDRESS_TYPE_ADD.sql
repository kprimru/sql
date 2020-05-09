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

ALTER PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_ADD]
	@addrtypeid TINYINT,
	@fatnote varchar(100),
	@fatdoc varchar(50),
	@text VARCHAR(50),
	@active BIT = 1,
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

		INSERT INTO dbo.FinancingAddressTypeTable (
			FAT_ID_ADDR_TYPE, FAT_DOC, FAT_NOTE, FAT_TEXT, FAT_ACTIVE
		) VALUES (
			@addrtypeid, @fatdoc, @fatnote, @text, @active
		)

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
GRANT EXECUTE ON [dbo].[FINANCING_ADDRESS_TYPE_ADD] TO rl_financing_address_type_w;
GO