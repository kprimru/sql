USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[SALE_OBJECT_EDIT]
	@soid SMALLINT,
	@soname VARCHAR(50),
	@taxid SMALLINT,
	--@sobill VARCHAR(50),
	--@soinvunit VARCHAR(50),
	--@sookei	VARCHAR(20),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.SaleObjectTable
		SET
			SO_NAME = @soname,
			SO_ID_TAX = @taxid,
			--SO_BILL_STR = @sobill,
			--SO_INV_UNIT = @soinvunit,
			--SO_OKEI = @sookei,
			SO_ACTIVE = @active
		WHERE SO_ID = @soid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SALE_OBJECT_EDIT] TO rl_sale_object_w;
GO