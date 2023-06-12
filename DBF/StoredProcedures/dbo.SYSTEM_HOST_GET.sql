USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_HOST_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_HOST_GET]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[SYSTEM_HOST_GET]
	@distrid INT
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

		DECLARE @sysid INT

		SELECT @sysid = SYS_ID
		FROM dbo.DistrView WITH(NOEXPAND)
		WHERE DIS_ID = @distrid

		SELECT SYS_ID, SYS_SHORT_NAME
		FROM dbo.SystemTable
		WHERE SYS_ID <> @sysid
			AND SYS_ID_HOST =
					(
						SELECT SYS_ID_HOST
						FROM dbo.SystemTable
						WHERE SYS_ID = @sysid
					)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_HOST_GET] TO rl_distr_w;
GRANT EXECUTE ON [dbo].[SYSTEM_HOST_GET] TO rl_host_r;
GRANT EXECUTE ON [dbo].[SYSTEM_HOST_GET] TO rl_system_r;
GO
