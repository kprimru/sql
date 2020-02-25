USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[FILE_ONLINE_XML_SELECT]
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

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
	
		SELECT
		(
			SELECT CONVERT(NVARCHAR(32), START, 104) AS '@week', HostReg AS '@host', DISTR AS '@distr', COMP AS '@comp', LGN AS '@login', ACTIVITY AS '@activity'
			FROM 
				dbo.OnlineActivity a
				INNER JOIN Common.Period b ON a.ID_WEEK = b.ID
				INNER JOIN dbo.Hosts c ON a.ID_HOST = HostID
				INNER JOIN Reg.RegNodeSearchView d WITH(NOEXPAND) ON c.HostID = d.HostID AND d.DistrNumber = a.DISTR AND d.CompNumber = a.COMP
			WHERE d.SubhostName = @SH
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
