USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STREET_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STREET_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STREET_INSERT]
	@CITY	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(150),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		INSERT INTO dbo.Street(ST_ID_CITY, ST_NAME, ST_PREFIX, ST_SUFFIX)
			OUTPUT INSERTED.ST_ID INTO @TBL
			VALUES(@CITY, @NAME, @PREFIX, @SUFFIX)

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
GRANT EXECUTE ON [dbo].[STREET_INSERT] TO rl_street_i;
GO
