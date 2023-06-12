USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[AREA_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[AREA_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[AREA_UPDATE]
	@ID	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(100),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20),
	@REGION	UNIQUEIDENTIFIER
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

		UPDATE	dbo.Area
		SET		AR_ID_REGION	=	@REGION,
				AR_NAME			=	@NAME,
				AR_PREFIX		=	@PREFIX,
				AR_SUFFIX		=	@SUFFIX
		WHERE	AR_ID			=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[AREA_UPDATE] TO rl_area_u;
GO
