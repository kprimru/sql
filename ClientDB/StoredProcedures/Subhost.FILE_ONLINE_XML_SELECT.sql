USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[FILE_ONLINE_XML_SELECT]
	@SH		NVARCHAR(16),
	@USR	NVARCHAR(128) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Distr Table
		(
			HostID	SmallInt	NOT NULL,
			Distr	Int			NOT NULL,
			Comp	TinyInt		NOT NULL,
			Primary Key Clustered(Distr, HostID, Comp)
		);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Distr
		SELECT HostID, DistrNumber, CompNumber
		FROM dbo.SubhostDistrs@Get(NULL, @SH);

		SELECT
		(
			SELECT CONVERT(NVARCHAR(32), START, 104) AS '@week', HostReg AS '@host', a.DISTR AS '@distr', a.COMP AS '@comp', LGN AS '@login', ACTIVITY AS '@activity'
			FROM
				dbo.OnlineActivity a
				INNER JOIN Common.Period b ON a.ID_WEEK = b.ID
				INNER JOIN dbo.Hosts c ON a.ID_HOST = HostID
				INNER JOIN @Distr d ON c.HostID = d.HostID AND d.Distr = a.DISTR AND d.Comp = a.COMP
			FOR XML PATH('online'), ROOT('root')
		) AS DATA

		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'ONLINE'
			FROM dbo.Subhost
			WHERE SH_REG = @SH
				AND @USR IS NOT NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[FILE_ONLINE_XML_SELECT] TO rl_web_subhost;
GO