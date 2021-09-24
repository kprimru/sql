USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STREET_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@CITY	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(150),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20)
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

		UPDATE	dbo.Street
		SET		ST_ID_CITY	=	@CITY,
				ST_NAME		=	@NAME,
				ST_PREFIX	=	@PREFIX,
				ST_SUFFIX	=	@SUFFIX
		WHERE ST_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STREET_UPDATE] TO rl_street_u;
GO
