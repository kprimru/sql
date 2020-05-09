USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_HISTORY]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE	@HOST	INT
		DECLARE	@DISTR	INT
		DECLARE	@COMP	TINYINT

		SELECT @HOST = ID_HOST, @DISTR = DISTR, @COMP = COMP
		FROM dbo.ClientDistr
		WHERE ID = @ID

		SELECT DISTINCT
			dbo.DistrString(SystemShortName, DISTR, COMP) AS DistrStr,
			DistrTypeName, DS_INDEX,
			ON_DATE, OFF_DATE,
			ClientFullName,
			a.BDATE, a.EDATE, a.UPD_USER
		FROM
			dbo.ClientDistr a
			INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.ClientID
			INNER JOIN dbo.SystemTable c ON a.ID_SYSTEM = c.SystemID
			INNER JOIN dbo.DistrTypeTable d ON a.ID_NET = d.DistrTypeID
			INNER JOIN dbo.DistrStatus e ON a.ID_STATUS = e.DS_ID
		WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP
		ORDER BY BDATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_HISTORY] TO rl_client_distr_history;
GO