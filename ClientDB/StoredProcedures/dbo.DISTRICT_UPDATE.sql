USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTRICT_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTRICT_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTRICT_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@CITY	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(100)
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

		UPDATE	dbo.District
		SET		DS_ID_CITY	=	@CITY,
				DS_NAME		=	@NAME
		WHERE DS_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTRICT_UPDATE] TO rl_district_u;
GO
