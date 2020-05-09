USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[TAX_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@NAME		NVARCHAR(128),
	@CAPTION	NVARCHAR(128),
	@RATE		DECIMAL(6, 2),
	@DEFAULT	BIT
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

		IF @DEFAULT = 1
			UPDATE Common.Tax
			SET [DEFAULT] = 0
			WHERE [DEFAULT] = 1
				AND ID <> @ID

		UPDATE	Common.Tax
		SET		NAME		=	@NAME,
				CAPTION		=	@CAPTION,
				RATE		=	@RATE,
				[DEFAULT]	=	@DEFAULT
		WHERE	ID			=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Common].[TAX_UPDATE] TO rl_tax_u;
GO