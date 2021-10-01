USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[TAX_INSERT]
	@NAME		NVARCHAR(128),
	@CAPTION	NVARCHAR(128),
	@RATE		DECIMAL(6, 2),
	@DEFAULT	BIT,
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Common.Tax(NAME, CAPTION, RATE, [DEFAULT])
			OUTPUT INSERTED.ID INTO @TBL
			VALUES(@NAME, @CAPTION, @RATE, @DEFAULT)

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Common].[TAX_INSERT] TO rl_tax_i;
GO
