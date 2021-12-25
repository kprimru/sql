USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_GET]
	@Id	UniqueIdentifier
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

		SELECT
			SH_ID, SH_NAME, SH_REG, SH_REG_ADD, SH_EMAIL, SH_ODD_EMAIL, SH_ID_CLIENT, SH_SEMINAR_DEFAULT_COUNT
		FROM dbo.Subhost a
		WHERE SH_ID = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
