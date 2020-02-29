USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTROL_INSERT]
	@CLIENT	INT,
	@TEXT	VARCHAR(MAX),
	@BEGIN	SMALLDATETIME = NULL
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

		DECLARE	@TYPE	SMALLINT

		SET @TYPE = NULL

		IF IS_MEMBER('rl_client_control_duty_set') = 1
			SET @TYPE = 3
		IF IS_MEMBER('rl_client_control_manager_set') = 1
			SET @TYPE = 2
		IF IS_MEMBER('rl_client_control_quality_set') = 1
			SET @TYPE = 1
		IF IS_MEMBER('rl_client_control_chief_set') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1
			SET @TYPE = 4
		IF IS_MEMBER('rl_client_control_lawyer_set') = 1
			SET @TYPE = 5
		
		IF @TYPE IS NULL
		BEGIN
			RAISERROR ('Вам запрещено ставить клиента на контроль', 16, 1)

			RETURN
		END

		INSERT INTO dbo.ClientControl(CC_ID_CLIENT, CC_BEGIN, CC_TEXT, CC_TYPE)
			SELECT @CLIENT, @BEGIN, @TEXT, @TYPE
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END