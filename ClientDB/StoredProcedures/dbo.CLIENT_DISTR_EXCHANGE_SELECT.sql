USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_EXCHANGE_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@SYSTEM	INT OUTPUT,
	@NET	INT OUTPUT,
	@DISTR	VARCHAR(50) OUTPUT,
	@HOST	INT	OUTPUT,
	@DATE	SMALLDATETIME = NULL OUTPUT
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

		SELECT @SYSTEM = c.SystemID, @DATE = CONVERT(SMALLDATETIME, RegisterDate, 104)
		FROM dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostId = a.HostId
															AND c.DistrNumber = a.DISTR
															AND c.CompNumber = a.COMP
		WHERE a.ID = @ID AND a.SystemID <> c.SystemID

		SELECT @NET = c.DistrTypeID, @DATE = CONVERT(SMALLDATETIME, RegisterDate, 104)
		FROM dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostId = a.HostId
														AND c.DistrNumber = a.DISTR
														AND c.CompNumber = a.COMP
		WHERE a.ID = @ID AND a.DistrTypeID <> c.DistrTypeID

		SELECT @DISTR = DistrStr, @HOST = HostID
		FROM dbo.ClientDistrView a WITH(NOEXPAND)
		WHERE ID = @ID

		IF (SELECT COUNT(*) FROM dbo.SystemTable WHERE HostID = @HOST) < 2
			SET @HOST = NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_EXCHANGE_SELECT] TO rl_client_distr_exchange;
GO