USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[HOTLINE_XML_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[HOTLINE_XML_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[HOTLINE_XML_SELECT]
	@SUBHOST	NVARCHAR(16),
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
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
				SYS AS '@sys', DISTR AS '@distr', COMP AS '@comp',
				CONVERT(NVARCHAR(64), FIRST_DATE, 120) AS '@first_date',
				CONVERT(NVARCHAR(64), START, 120) AS '@start',
				CONVERT(NVARCHAR(64), FINISH, 120) AS '@finish',
				PROFILE AS 'profile',
				FIO AS 'fio', EMAIL AS 'email', PHONE AS 'phone', CHAT AS 'text',
				LGN AS 'lgn', RIC_PERSONAL AS 'personal'
			FROM
				dbo.HotlineChat a
				INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
				INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
			WHERE c.SubhostName = @SUBHOST
				AND (a.START >= @START OR @START IS NULL)
				AND (a.START < @FINISH OR @FINISH IS NULL)
			ORDER BY a.START DESC
			FOR XML PATH('chat'), ROOT('root')
		), N'<root/>') AS DATA

		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'HOTLINE'
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
GRANT EXECUTE ON [Subhost].[HOTLINE_XML_SELECT] TO rl_web_subhost;
GO
