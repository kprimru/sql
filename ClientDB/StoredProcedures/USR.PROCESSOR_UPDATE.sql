USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[PROCESSOR_UPDATE]
	@ID		INT,
	@NAME	VARCHAR(100),
	@FREQ_S	VARCHAR(50),
	@FREQ	DECIMAL(8, 4),
	@CORE	SMALLINT,
	@PF_ID	INT
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

		UPDATE USR.Processor
		SET	PRC_NAME = @NAME,
			PRC_FREQ_S = @FREQ_S,
			PRC_FREQ = @FREQ,
			PRC_CORE = @CORE,
			PRC_ID_FAMILY = @PF_ID
		WHERE PRC_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[PROCESSOR_UPDATE] TO rl_processor_u;
GO
