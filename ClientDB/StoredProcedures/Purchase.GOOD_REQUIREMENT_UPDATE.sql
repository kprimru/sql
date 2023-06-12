USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[GOOD_REQUIREMENT_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[GOOD_REQUIREMENT_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[GOOD_REQUIREMENT_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(4000),
	@SHORT	VARCHAR(200)
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

		UPDATE Purchase.GoodRequirement
		SET GR_NAME		=	@NAME,
			GR_SHORT	=	@SHORT
		WHERE GR_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[GOOD_REQUIREMENT_UPDATE] TO rl_good_requirement_u;
GO
