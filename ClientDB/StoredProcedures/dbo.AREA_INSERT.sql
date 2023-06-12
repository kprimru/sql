USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[AREA_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[AREA_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[AREA_INSERT]
	@NAME	VARCHAR(100),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20),
	@REGION	UNIQUEIDENTIFIER,
	@ID	UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.Area(AR_ID_REGION, AR_NAME, AR_PREFIX, AR_SUFFIX)
			OUTPUT INSERTED.AR_ID INTO @TBL
			VALUES(@REGION, @NAME, @PREFIX, @SUFFIX)

		SELECT @ID = ID
		FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[AREA_INSERT] TO rl_area_i;
GO
