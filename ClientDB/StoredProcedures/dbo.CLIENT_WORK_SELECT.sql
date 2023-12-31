USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_WORK_SELECT]
	@CLIENT	INT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@TYPE	NVARCHAR(MAX)
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

		SELECT ClientID, TP, DT, NOTE, AUTHOR
		FROM dbo.ClientWorkView
		WHERE ClientID = @CLIENT
			AND (DT >= @BEGIN OR @BEGIN IS NULL)
			AND (DT <= @END OR @END IS NULL)
			AND
				(
					TP IN (SELECT ID FROM dbo.TableStringFromXML(@TYPE))
					OR @TYPE IS NULL
				)
		ORDER BY DT DESC, TP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_WORK_SELECT] TO rl_report;
GO
