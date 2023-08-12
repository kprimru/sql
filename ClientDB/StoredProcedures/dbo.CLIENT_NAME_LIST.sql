USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_NAME_LIST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_NAME_LIST]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_NAME_LIST]
	@LIST	NVARCHAR(MAX)
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
				REVERSE(STUFF(REVERSE(
					(
						SELECT a.ClientFullName + ', '
						FROM
							dbo.ClientTable a
							INNER JOIN dbo.TableIDFromXML(@LIST) b ON a.ClientID = b.ID
						ORDER BY a.ClientFullName FOR XML PATH('')
					)
					), 1, 2, '')) AS NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_NAME_LIST] TO public;
GO
