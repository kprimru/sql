USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[FILE_CLIENT_STAT_XML_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[FILE_CLIENT_STAT_XML_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[FILE_CLIENT_STAT_XML_SELECT]
	@SUBHOST	NVARCHAR(16),
	@USR		NVARCHAR(128) = NULL
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

		SELECT
			ISNULL((
				SELECT
					[UpDate]			= a.[UpDate],
					[WeekStart] 		= b.START,
					[HostReg]			= d.HostReg,
					[Distr]				= a.Distr,
					[Comp]				= a.Comp,
					[Net]				= a.Net,
					[UserCount]			= a.UserCount,
					[EnterSum]			= a.EnterSum,
					[Enter0]			= a.[0Enter],
					[Enter1]			= a.[1Enter],
					[Enter2]			= a.[2Enter],
					[Enter3]			= a.[3Enter],
					[SessionTimeSum]	= a.SessionTimeSum,
					[SessionTimeAVG]	= a.SessionTimeAVG
				FROM
					dbo.ClientStatDetail a
					INNER JOIN Common.Period b ON a.WeekId = b.ID
					INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = a.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
					INNER JOIN dbo.Hosts d ON a.HostID = d.HostID
				WHERE c.SubhostName = @SUBHOST
				ORDER BY b.START DESC
				FOR XML RAW('client_stat'), ROOT('root')
			), N'<root/>') AS DATA

		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'CLIENT_STAT'
			FROM dbo.Subhost
			WHERE SH_REG = @SUBHOST
				AND @USR IS NOT NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[FILE_CLIENT_STAT_XML_SELECT] TO rl_web_subhost;
GO
