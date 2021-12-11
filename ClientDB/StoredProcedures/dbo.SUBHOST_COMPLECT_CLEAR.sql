USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_COMPLECT_CLEAR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_COMPLECT_CLEAR]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_COMPLECT_CLEAR]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT
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

		DELETE
		FROM dbo.SubhostComplect
		WHERE SC_ID_HOST	=	@HOST
			AND SC_DISTR	=	@DISTR
			AND SC_COMP		=	@COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_COMPLECT_CLEAR] TO rl_reg_node_subhost;
GO
