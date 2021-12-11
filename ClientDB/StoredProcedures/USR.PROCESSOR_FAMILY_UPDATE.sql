USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[PROCESSOR_FAMILY_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[PROCESSOR_FAMILY_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[PROCESSOR_FAMILY_UPDATE]
	@ID		INT,
	@NAME	VARCHAR(150)
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

		UPDATE USR.ProcessorFamily
		SET PF_NAME = @NAME
		WHERE PF_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[PROCESSOR_FAMILY_UPDATE] TO rl_proc_family_u;
GO
