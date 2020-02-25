USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[FILE_NOTES_XML_SELECT]
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

		SELECT [DATA] = 
			(
				SELECT
					SystemBaseName AS '@Reg',
					[Note] = NOTE,
					[Note_WTitle] = NOTE_WTITLE
				FROM dbo.SystemNote N
				INNER JOIN dbo.SystemTable S ON N.ID_SYSTEM = S.SystemID
				FOR XML PATH('System')
			);
		
		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'SYS_NOTES'
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
