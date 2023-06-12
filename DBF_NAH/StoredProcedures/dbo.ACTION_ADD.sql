USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACTION_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACTION_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACTION_ADD]
	@NAME	VARCHAR(50),
	@TYPE	SMALLINT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@PERIOD	VARCHAR(MAX),
	@ACTIVE	BIT = 1,
	@RETURN	BIT = 1
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

		DECLARE @ID	SMALLINT

		IF @PERIOD IS NULL
		BEGIN
			INSERT INTO dbo.Action(ACTN_NAME, ACTN_ID_TYPE, ACTN_BEGIN, ACTN_END, ACTN_ACTIVE)
				VALUES(@NAME, @TYPE, @BEGIN, @END, @ACTIVE)

			SET @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			INSERT INTO dbo.Action(ACTN_NAME, ACTN_ID_TYPE, ACTN_ACTIVE)
				VALUES(@NAME, @TYPE, @ACTIVE)

			SET @ID = SCOPE_IDENTITY()

			INSERT INTO dbo.ActionPeriod(AP_ID_AC, AP_ID_PERIOD)
				SELECT @ID, Item
				FROM dbo.GET_TABLE_FROM_LIST(@PERIOD, ',')
		END

		IF @RETURN = 1
			SELECT @ID AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACTION_ADD] TO rl_action_w;
GO
