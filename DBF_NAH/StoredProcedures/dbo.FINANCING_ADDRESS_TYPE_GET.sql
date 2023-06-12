USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FINANCING_ADDRESS_TYPE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_GET]  AS SELECT 1')
GO



/*
Автор:			Денисов Алексей
Дата:			2 July 2009
Описание:
*/

ALTER PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_GET]
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

		SELECT FAT_ID, FAT_ID_ADDR_TYPE, FAT_DOC, FAT_NOTE, FAT_TEXT, AT_NAME, FAT_ACTIVE
			FROM	dbo.FinancingAddressTypeTable	A		LEFT OUTER JOIN
					dbo.AddressTypeTable			B	ON	A.FAT_ID_ADDR_TYPE=B.AT_ID
		WHERE
			FAT_ID = @fatid
		ORDER BY AT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[FINANCING_ADDRESS_TYPE_GET] TO rl_financing_address_type_r;
GO
