USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Din].[DIN_FILES_SELECT]
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
			CASE DF_RIC
				WHEN 20 THEN ''
				ELSE '–»÷ ' + CONVERT(VARCHAR(20), DF_RIC) + '\'
			END + NT_NAME +
			CASE NT_NOTE
				WHEN '' THEN ''
				ELSE ', ' + NT_NOTE
			END + '\' + DF_FILE +
			CASE RN
				WHEN 1 THEN ''
				ELSE '-' + CONVERT(VARCHAR(20), RN)
			END AS DIN_PATH,
			DF_DIN, DF_CREATE
		FROM
			(
				SELECT
					NT_NAME, NT_NOTE,
					DF_FILE, DF_RIC, DF_DIN, DF_CREATE,
					ROW_NUMBER() OVER(PARTITION BY DF_RIC, DF_FILE, NT_NAME, NT_NOTE ORDER BY DF_RIC, DF_FILE, NT_NAME, NT_NOTE) AS RN
				FROM
					Din.DinFiles a
					INNER JOIN Din.NetType b ON a.DF_ID_NET = NT_ID
			) AS d

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[DIN_FILES_SELECT] TO rl_din_import;
GO