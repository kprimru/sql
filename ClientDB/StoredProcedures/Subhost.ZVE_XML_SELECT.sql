USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[ZVE_XML_SELECT]
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

		IF @START IS NULL AND @FINISH IS NULL
		BEGIN
			SET @START = '20171023'
			SET @FINISH = NULL
		END

		SELECT
		(
			SELECT 
				SYS AS '@sys', DISTR AS '@distr', COMP AS '@comp', CONVERT(NVARCHAR(64), DATE, 120) AS '@date', 
				FIO AS 'fio', EMAIL AS 'email', PHONE AS 'phone', QUEST AS 'text'
			FROM 
				dbo.ClientDutyQuestion a
				INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
				INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
			WHERE c.SubhostName = @SUBHOST
				AND (a.DATE >= @START OR @START IS NULL)
				AND (a.DATE < @FINISH OR @FINISH IS NULL)
			ORDER BY a.DATE DESC	
			FOR XML PATH('quest'), ROOT('root')
		) AS DATA
		
		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'ZVE'
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
