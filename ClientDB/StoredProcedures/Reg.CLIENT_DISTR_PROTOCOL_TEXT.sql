USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[CLIENT_DISTR_PROTOCOL_TEXT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Reg].[CLIENT_DISTR_PROTOCOL_TEXT]  AS SELECT 1')
GO
ALTER PROCEDURE [Reg].[CLIENT_DISTR_PROTOCOL_TEXT]
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

		SELECT DATE, CNT, COMMENT
		FROM Reg.ProtocolText
		WHERE ID_HOST = @HST AND DISTR = @DISTR AND COMP = @COMP
		ORDER BY DATE DESC, ID DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Reg].[CLIENT_DISTR_PROTOCOL_TEXT] TO rl_client_distr_protocol;
GRANT EXECUTE ON [Reg].[CLIENT_DISTR_PROTOCOL_TEXT] TO rl_client_system_protocol;
GO
