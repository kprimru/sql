USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_COMPLECT_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_COMPLECT_SET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_COMPLECT_SET]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@SH_ID	UNIQUEIDENTIFIER,
	@REG	BIT,
	@USR	BIT
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

		UPDATE dbo.SubhostComplect
		SET SC_ID_SUBHOST	=	@SH_ID,
			SC_REG			=	@REG,
			SC_USR			=	@USR
		WHERE SC_ID_HOST	=	@HOST
			AND SC_DISTR	=	@DISTR
			AND SC_COMP		=	@COMP

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.SubhostComplect(SC_ID_SUBHOST, SC_ID_HOST, SC_DISTR, SC_COMP, SC_REG, SC_USR)
				VALUES(@SH_ID, @HOST, @DISTR, @COMP, @REG, @USR)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_COMPLECT_SET] TO rl_reg_node_subhost;
GO
