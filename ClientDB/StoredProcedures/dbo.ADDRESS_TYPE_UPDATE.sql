USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ADDRESS_TYPE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ADDRESS_TYPE_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[ADDRESS_TYPE_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@NAME		VARCHAR(100),
	@REQUIRED	BIT
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

		UPDATE	dbo.AddressType
		SET		AT_NAME		=	@NAME,
				AT_REQUIRED	=	@REQUIRED
		WHERE	AT_ID	=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ADDRESS_TYPE_UPDATE] TO rl_address_type_u;
GO
