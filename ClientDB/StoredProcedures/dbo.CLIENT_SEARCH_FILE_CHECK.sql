USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SEARCH_FILE_CHECK]
	@MD5	VARCHAR(100),
	@FILE	VARBINARY(MAX)
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

		IF EXISTS
			(
				SELECT *
				FROM dbo.ClientSearchFiles
				WHERE CSF_MD5 = @MD5
			)
		BEGIN
			IF EXISTS
				(
					SELECT *
					FROM dbo.ClientSearchFiles
					WHERE CSF_FILE = @FILE
						AND CSF_MD5 = @MD5
				)
			BEGIN
				SELECT ClientID, ClientFullName, CSF_DATE
				FROM
					dbo.ClientSearchFiles
					INNER JOIN dbo.ClientTable ON CSF_ID_CLIENT = ClientID
				WHERE CSF_MD5 = @MD5 AND CSF_FILE = @FILE
				ORDER BY CSF_DATE DESC
			END
			ELSE
			BEGIN
				SELECT ClientID, ClientFullName, CSF_DATE
				FROM
					dbo.ClientSearchFiles
					INNER JOIN dbo.ClientTable ON CSF_ID_CLIENT = ClientID
				WHERE 1 = 0
				ORDER BY CSF_DATE DESC
			END
		END
		ELSE
		BEGIN
			SELECT ClientID, ClientFullName, CSF_DATE
			FROM
				dbo.ClientSearchFiles
				INNER JOIN dbo.ClientTable ON CSF_ID_CLIENT = ClientID
			WHERE 1 = 0
			ORDER BY CSF_DATE DESC
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END