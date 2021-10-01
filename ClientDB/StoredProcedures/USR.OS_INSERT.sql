USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[OS_INSERT]
	@NAME	VARCHAR(100),
	@MIN	SMALLINT,
	@MAJ	SMALLINT,
	@BUILD	SMALLINT,
	@PLATFORM	TINYINT,
	@EDITION	VARCHAR(100),
	@CAPACITY	VARCHAR(50),
	@LANG		VARCHAR(50),
	@COMPATIBILITY	VARCHAR(100),
	@FAMILY	INT,
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

		INSERT INTO USR.OS(OS_NAME, OS_MIN, OS_MAJ, OS_BUILD, OS_PLATFORM, OS_EDITION, OS_CAPACITY, OS_LANG, OS_COMPATIBILITY, OS_ID_FAMILY)
			VALUES(@NAME, @MIN, @MAJ, @BUILD, @PLATFORM, @EDITION, @CAPACITY, @LANG, @COMPATIBILITY, @FAMILY)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[OS_INSERT] TO rl_os_i;
GO
