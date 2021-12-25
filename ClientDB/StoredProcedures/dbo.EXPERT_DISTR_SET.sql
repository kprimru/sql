USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EXPERT_DISTR_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EXPERT_DISTR_SET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EXPERT_DISTR_SET]
	@HOST	INT,
	@DISTR	INT,
	@COMP	INT,
	@STATE	BIT
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

		IF @STATE = 1 AND NOT EXISTS (SELECT * FROM dbo.ExpertDistr WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP AND STATUS = 1)
			INSERT INTO dbo.ExpertDistr(ID_HOST, DISTR, COMP)
				VALUES(@HOST, @DISTR, @COMP)
		ELSE IF @STATE = 0 AND EXISTS (SELECT * FROM dbo.ExpertDistr WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP AND STATUS = 1)
			UPDATE dbo.ExpertDistr
			SET STATUS = 2,
				UNSET_DATE = GETDATE(),
				UNSET_USER = ORIGINAL_LOGIN()
			WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP AND STATUS = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EXPERT_DISTR_SET] TO rl_expert_distr;
GO
