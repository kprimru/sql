USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTACT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTACT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTACT_SELECT]
	@CLIENT	INT,
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME,
	@TYPE	NVARCHAR(MAX),
	@SEARCH	NVARCHAR(MAX)
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
			a.ID, DATE, PERSONAL, SURNAME + ' ' + a.NAME + ' ' + PATRON + ' (' + POSITION + ')' AS FIO,
			b.NAME, CATEGORY, NOTE, PROBLEM,
			CONVERT(NVARCHAR(64), a.UPD_DATE, 104) + ' ' + CONVERT(NVARCHAR(64), a.UPD_DATE, 108) + ' - ' + a.UPD_USER AS UPDATE_DATA,
			CONVERT(NVARCHAR(64), z.UPD_DATE, 104) + ' ' + CONVERT(NVARCHAR(64), z.UPD_DATE, 108) + ' - ' + z.UPD_USER AS CREATE_DATA
		FROM
			dbo.ClientContact a
			INNER JOIN dbo.ClientContactType b ON a.ID_TYPE = b.ID
			OUTER APPLY
			(
			    SELECT TOP (1) UPD_DATE, UPD_USER
			    FROM
			    (
				    SELECT TOP 1 UPD_DATE, UPD_USER
				    FROM dbo.ClientContact z
				    WHERE z.ID_MASTER = a.ID
				    ORDER BY UPD_DATE
    
				    UNION ALL
    
				    SELECT TOP 1 UPD_DATE, UPD_USER
				    FROM dbo.ClientContact z
				    WHERE z.ID = a.ID
				    ORDER BY UPD_DATE
				) AS z
				ORDER BY UPD_DATE
			) AS z
		WHERE STATUS = 1
			AND ID_CLIENT = @CLIENT
			AND (DATE >= @START OR @START IS NULL)
			AND (DATE <= @FINISH OR @FINISH IS NULL)
			AND (@TYPE IS NULL OR @TYPE IN (SELECT ID FROM dbo.TableGUIDFromXML(@TYPE)))
			AND (@SEARCH IS NULL OR @SEARCH = '' OR NOTE LIKE @SEARCH OR PROBLEM LIKE @SEARCH)
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTACT_SELECT] TO rl_client_contact_r;
GO
