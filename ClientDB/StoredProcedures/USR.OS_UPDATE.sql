USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[OS_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[OS_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[OS_UPDATE]
	@ID		INT,
	@NAME	VARCHAR(100),
	@MIN	SMALLINT,
	@MAJ	SMALLINT,
	@BUILD	SMALLINT,
	@PLATFORM	TINYINT,
	@EDITION	VARCHAR(100),
	@CAPACITY	VARCHAR(50),
	@LANG		VARCHAR(50),
	@COMPATIBILITY	VARCHAR(100),
	@FAMILY	INT
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

		UPDATE USR.OS
		SET	OS_NAME = @NAME,
			OS_MIN = @MIN,
			OS_MAJ = @MAJ,
			OS_BUILD = @BUILD,
			OS_PLATFORM = @PLATFORM,
			OS_EDITION = @EDITION,
			OS_CAPACITY = @CAPACITY,
			OS_LANG = @LANG,
			OS_COMPATIBILITY = @COMPATIBILITY,
			OS_ID_FAMILY = @FAMILY
		WHERE OS_ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[OS_UPDATE] TO rl_os_u;
GO
