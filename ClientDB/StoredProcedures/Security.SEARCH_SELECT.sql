USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[SEARCH_SELECT]
	@TYPE	NVARCHAR(64)
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

		DECLARE @CNT	INT

		SELECT @CNT = ST_SR_COUNT
		FROM dbo.Settings
		WHERE ST_USER = ORIGINAL_LOGIN()
			AND ST_HOST = HOST_NAME()

		IF @CNT IS NULL
			SET @CNT = 10

		SELECT TOP (@CNT) CS_ID, CS_SHORT, CS_DATE
		FROM
			(
				SELECT CS_ID, CS_SHORT, CS_DATE, CS_FREEZE, ROW_NUMBER() OVER(PARTITION BY CS_SHORT ORDER BY CS_DATE DESC) AS RN
				FROM Security.ClientSearch
				WHERE CS_TYPE = @TYPE
					AND CS_FREEZE = 0
					AND CS_HOST = HOST_NAME()
					AND CS_USER = ORIGINAL_LOGIN()
			) AS o_O
		WHERE RN = 1
		ORDER BY CS_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Security].[SEARCH_SELECT] TO public;
GO