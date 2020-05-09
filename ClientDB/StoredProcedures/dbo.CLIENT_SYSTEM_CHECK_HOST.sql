USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SYSTEM_CHECK_HOST]
	@ID		INT,
	@SYS	INT,
	@DISTR	INT,
	@COMP	TINYINT
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

		DECLARE @HST INT

		SELECT @HST = HostID
		FROM dbo.SystemTable
		WHERE SystemID = @SYS

		SELECT ID
		FROM
			dbo.ClientSystemsTable a
			INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
		WHERE HostID = @HST AND SystemDistrNumber = @DISTR AND CompNumber = @COMP
			AND (a.ID <> @ID OR @ID IS NULL)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SYSTEM_CHECK_HOST] TO rl_client_system_r;
GO