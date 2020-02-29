USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[PROCESSOR_INSERT]
	@NAME	VARCHAR(100),
	@FREQ_S	VARCHAR(50),
	@FREQ	DECIMAL(8, 4),
	@CORE	SMALLINT,
	@PF_ID	INT,
	@ID		INT = NULL OUTPUT
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

		INSERT INTO USR.Processor(PRC_NAME, PRC_FREQ_S, PRC_FREQ, PRC_CORE, PRC_ID_FAMILY)
			SELECT @NAME, @FREQ_S, @FREQ, @CORE, @PF_ID

		SELECT @ID = SCOPE_IDENTITY()
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END