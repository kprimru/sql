USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_SALE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_SALE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_SALE_SELECT]
	@CLIENT	INT
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
		    ID, DATE, FIO, LPR, USER_POST, NOTE,
		    ('<LIST>' +
				(
					SELECT CONVERT(VARCHAR(50), R.RivalType_Id)AS ITEM
					FROM dbo.StudySaleRivals AS R
		            WHERE R.StudySale_Id = S.ID
					FOR XML PATH('')
				)
			+ '</LIST>') AS RivalType_IDs,
		    REVERSE(STUFF(REVERSE(
		        (
		            SELECT Cast(T.RivalTypeName AS VarChar(100)) + ','
		            FROM dbo.StudySaleRivals AS R
		            INNER JOIN dbo.RivalTypeTable AS T ON T.RivalTypeID = R.RivalType_Id
		            WHERE R.StudySale_Id = S.ID
		            FOR XML PATH('')
		        )
		    ), 1, 1, '')) AS RIVAL_CLIENT
		FROM dbo.StudySale AS S
		WHERE ID_CLIENT = @CLIENT
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
GRANT EXECUTE ON [dbo].[STUDY_SALE_SELECT] TO rl_client_study_r;
GO
