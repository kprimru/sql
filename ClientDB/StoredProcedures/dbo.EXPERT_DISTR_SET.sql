USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EXPERT_DISTR_SET]
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

		IF @STATE = 1 AND NOT EXISTS (SELECT * FROM dbo.ExpDistr WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP AND STATUS = 1)
			INSERT INTO dbo.ExpDistr(ID_HOST, DISTR, COMP)
				VALUES(@HOST, @DISTR, @COMP)
		ELSE IF @STATE = 0 AND EXISTS (SELECT * FROM dbo.ExpDistr WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP AND STATUS = 1)
			UPDATE dbo.ExpDistr
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
