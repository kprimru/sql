USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Poll].[BLANK_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Poll].[BLANK_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Poll].[BLANK_SELECT]
	@FILTER	NVARCHAR(256) = NULL
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

		SELECT B.ID, B.NAME, D.DATE
		FROM Poll.Blank AS B
		OUTER APPLY
		(
		    SELECT TOP (1) CP.DATE
		    FROM Poll.ClientPoll AS CP
		    WHERE CP.ID_BLANK = B.ID
		    ORDER BY CP.DATE DESC
		) AS D
		WHERE @FILTER IS NULL
			OR NAME LIKE @FILTER
		ORDER BY
		    CASE WHEN D.DATE IS NULL THEN 100 ELSE 1 END,
		    D.DATE DESC,
		    B.NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Poll].[BLANK_SELECT] TO rl_blank_r;
GO
