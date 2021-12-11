USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INNOVATION_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INNOVATION_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[INNOVATION_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(256),
	@NOTE	NVARCHAR(MAX),
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME
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

		UPDATE dbo.Innovation
		SET NAME	=	@NAME,
			NOTE	=	@NOTE,
			START	=	@START,
			FINISH	=	@FINISH
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INNOVATION_UPDATE] TO rl_innovation_u;
GO
