USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REGION_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(100),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20),
	@NUM	TINYINT
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

		UPDATE dbo.Region
		SET RG_NAME		=	@NAME,
			RG_PREFIX	=	@PREFIX,
			RG_SUFFIX	=	@SUFFIX,
			RG_NUM		=	@NUM
		WHERE RG_ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REGION_UPDATE] TO rl_region_u;
GO