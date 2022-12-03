USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[LETTER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[LETTER_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[LETTER_SELECT]
	@SH		NVARCHAR(64),
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME,
	@NUM	NVARCHAR(256),
	@TEXT	NVARCHAR(256)
WITH EXECUTE AS OWNER
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

		DECLARE @RC INT
		DECLARE @RECEIVER NVARCHAR(64)

		SET @RECEIVER =
				CASE @SH
					WHEN 'Н1' THEN 'f0ec56ff-5ae4-e211-bb69-000c2933b2fd'
					WHEN 'У1' THEN 'f1ec56ff-5ae4-e211-bb69-000c2933b2fd'
					WHEN 'Л1' THEN 'a92b3b06-5be4-e211-bb69-000c2933b2fd'
					WHEN 'М' THEN 'f2ec56ff-5ae4-e211-bb69-000c2933b2fd'
					WHEN 'В' THEN '3e2c9f7e-a56f-ed11-8c9a-0007e92aafc5'
				END

		EXEC [Letters].[dbo.LETTER_SEARCH] '8ebc1b48-59e4-e211-bb69-000c2933b2fd', @START, @FINISH, @NUM, @TEXT, @RC OUTPUT, @RECEIVER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[LETTER_SELECT] TO rl_web_subhost;
GO
