USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACTION_EDIT]
	@ID		SMALLINT,
	@NAME	VARCHAR(50),
	@TYPE	SMALLINT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@PERIOD	VARCHAR(MAX),
	@ACTIVE	BIT
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

		IF @PERIOD IS NULL
		BEGIN
			DELETE 
			FROM dbo.ActionPeriod
			WHERE AP_ID_AC = @ID
		
			UPDATE dbo.Action
			SET	ACTN_ID_TYPE	= @TYPE,
				ACTN_NAME	=	@NAME,
				ACTN_BEGIN	=	@BEGIN,
				ACTN_END	=	@END,
				ACTN_ACTIVE =	@ACTIVE
			WHERE ACTN_ID = @ID
		END
		ELSE
		BEGIN
			DELETE
			FROM dbo.ActionPeriod
			WHERE AP_ID_AC = @ID
				AND AP_ID_PERIOD NOT IN
					(
						SELECT Item
						FROM dbo.GET_TABLE_FROM_LIST(@PERIOD, ',')
					)

			INSERT INTO dbo.ActionPeriod(AP_ID_AC, AP_ID_PERIOD)
				SELECT @ID, Item
				FROM dbo.GET_TABLE_FROM_LIST(@PERIOD, ',')
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.ActionPeriod
						WHERE AP_ID_AC = @ID
							AND AP_ID_PERIOD = Item
					)

			UPDATE dbo.Action
			SET	ACTN_ID_TYPE = @TYPE,
				ACTN_NAME = @NAME,
				ACTN_BEGIN = NULL,
				ACTN_END = NULL,
				ACTN_ACTIVE = @ACTIVE
			WHERE ACTN_ID = @ID
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ACTION_EDIT] TO rl_action_w;
GO