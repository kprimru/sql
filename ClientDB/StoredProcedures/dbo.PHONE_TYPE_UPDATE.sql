USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PHONE_TYPE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PHONE_TYPE_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[PHONE_TYPE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(50),
	@SHORT	VARCHAR(20)
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

		UPDATE	dbo.PhoneType
		SET		PT_NAME	=	@NAME,
				PT_SHORT=	@SHORT
		WHERE	PT_ID	=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PHONE_TYPE_UPDATE] TO rl_phone_type_r;
GO
