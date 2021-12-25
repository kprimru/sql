USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_TYPE_SUBHOST_SET]
	@SH_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@CHECK	BIT,
	@HOST	SMALLINT,
	@DHOST	SMALLINT
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

		IF (@CHECK = 1)
		BEGIN
			UPDATE dbo.SystemTypeSubhost
			SET STS_ID_HOST = @HOST,
				STS_ID_DHOST = @DHOST
			WHERE STS_ID_SUBHOST = @SH_ID
				AND STS_ID_TYPE = @SST_ID

			IF @@ROWCOUNT = 0
				INSERT INTO dbo.SystemTypeSubhost(STS_ID_SUBHOST, STS_ID_TYPE, STS_ID_HOST, STS_ID_DHOST)
					VALUES(@SH_ID, @SST_ID, @HOST, @DHOST)
		END
		ELSE
			DELETE
			FROM dbo.SystemTypeSubhost
			WHERE STS_ID_SUBHOST = @SH_ID
				AND STS_ID_TYPE = @SST_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_SUBHOST_SET] TO rl_subhost_w;
GO
