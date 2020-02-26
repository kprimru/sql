USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_ORI_SAVE]
	@CLIENT			INT,
	@NAME			VARCHAR(250),
	@VISIT			VARCHAR(100),
	@INFO			VARCHAR(MAX),
	@RES_NAME		VARCHAR(250),
	@RES_PHONE		VARCHAR(100),
	@RES_POS		VARCHAR(100),
	@RES_PLACE		VARCHAR(100),
	@STUDY			VARCHAR(100),
	@CLAIM			VARCHAR(MAX),
	@CURR_STATUS	VARCHAR(100),
	@PLAN_ACTION	VARCHAR(MAX),
	@RESULT			VARCHAR(MAX),
	@RIVAL			VARCHAR(MAX),
	@NOTE			VARCHAR(MAX)
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

		IF EXISTS
			(
				SELECT *
				FROM dbo.ClientOri
				WHERE CO_ID_CLIENT = @CLIENT
					AND CO_STATUS = 1
			)
		BEGIN
			UPDATE dbo.ClientOri
			SET CO_STATUS = 2
			WHERE CO_ID_CLIENT = @CLIENT
				AND CO_STATUS = 1
		END
		
		INSERT INTO dbo.ClientOri(
						CO_ID_CLIENT, CO_NAME, CO_VISIT, CO_INFORMATION, CO_RES_NAME, CO_RES_PHONE, CO_RES_POSITION, CO_RES_PLACE, 
						CO_STUDY, CO_CLAIM, CO_CURR_STATUS, CO_PLAN_ACTION, CO_RESULT, CO_RIVAL, CO_NOTE)
			VALUES(		@CLIENT, @NAME, @VISIT, @INFO, @RES_NAME, @RES_PHONE, @RES_POS, @RES_PLACE, 
						@STUDY, @CLAIM, @CURR_STATUS, @PLAN_ACTION, @RESULT, @RIVAL, @NOTE)
						
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END