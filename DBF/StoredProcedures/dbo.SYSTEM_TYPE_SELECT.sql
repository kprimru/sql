USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_TYPE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_TYPE_SELECT]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[SYSTEM_TYPE_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT SST_ID, SST_NAME, SST_CAPTION, SST_REPORT, SST_LST,
			(
				SELECT SST_CAPTION
				FROM dbo.SystemTypeTable b
				WHERE b.SST_ID = a.SST_ID_SUB
			) AS SST_SUB,
			(
				SELECT SST_CAPTION
				FROM dbo.SystemTypeTable c
				WHERE c.SST_ID = a.SST_ID_MOS
			) AS SST_MOS
		FROM dbo.SystemTypeTable a
		WHERE SST_ACTIVE = ISNULL(@active, SST_ACTIVE)
		ORDER BY SST_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_SELECT] TO rl_system_type_r;
GO
