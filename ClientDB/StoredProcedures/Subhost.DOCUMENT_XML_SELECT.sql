USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[DOCUMENT_XML_SELECT]
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
			SELECT CONVERT(NVARCHAR(64), DATE, 120) AS '@date', SYS_NUM AS '@sys', DISTR AS '@distr', COMP AS '@comp', IB AS '@ib', IB_NUM AS '@ib_num', DOC_NAME AS 'doc_name'
			FROM
				dbo.ControlDocument a
				INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
				INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON b.HostID = c.HostID AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber
			WHERE c.SubhostName = @SUBHOST
				AND (a.DATE >= @START OR @START IS NULL)
				AND (a.DATE < @FINISH OR @FINISH IS NULL)
			FOR XML PATH('document'), ROOT('root')
		), '<root/>') AS DATA

		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'DOCUMENT'
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
GRANT EXECUTE ON [Subhost].[DOCUMENT_XML_SELECT] TO rl_web_subhost;
GO