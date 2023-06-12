USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_PROTOCOL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_PROTOCOL]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_PROTOCOL]
	@ID		UNIQUEIDENTIFIER	= NULL,
	@STR	VARCHAR(50)			= NULL OUTPUT,
	@HST	INT					= NULL,
	@DISTR	INT					= NULL,
	@COMP	TINYINT				= NULL
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

		IF @ID IS NOT NULL
			SELECT
				@HST = HostID, @DISTR = DISTR, @COMP = COMP,
				@STR = DistrStr
			FROM dbo.ClientDistrView a WITH(NOEXPAND)
			WHERE ID = @ID
		ELSE
			SELECT @STR = DistrStr
			FROM
				Reg.RegNodeSearchView a WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
			WHERE b.HostID = @HST AND DistrNumber = @DISTR AND CompNumber = @COMP


		SELECT RPR_DATE, RPR_OPER, RPR_REG, RPR_TYPE, RPR_TEXT, RPR_USER
		FROM dbo.RegProtocol
		WHERE RPR_ID_HOST = @HST AND RPR_DISTR = @DISTR AND RPR_COMP = @COMP
		ORDER BY RPR_DATE DESC, RPR_ID DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_PROTOCOL] TO rl_client_distr_protocol;
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_PROTOCOL] TO rl_client_system_protocol;
GO
