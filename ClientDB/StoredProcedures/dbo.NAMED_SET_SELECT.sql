USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[NAMED_SET_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[NAMED_SET_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[NAMED_SET_SELECT]
	@REFNAME	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE
			@SQL		NVARCHAR(MAX),
			@VALUE_TYPE	NVARCHAR(20);

		SELECT @VALUE_TYPE = DATA_TYPE
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_SCHEMA + '.' + TABLE_NAME = @REFNAME
			AND COLUMN_NAME=
				(
					SELECT ValueColumn
					FROM dbo.RefColumnMeta
					WHERE RefName = @REFNAME
				);

		SELECT @SQL='
			SELECT
				SetName,
				(
					SELECT STUFF(CAST(('
						+
						CASE																--для того чтобы дробные числа отображались с запятой, а не с точкой
						WHEN @VALUE_TYPE='float' OR @VALUE_TYPE='real'
						THEN
							'SELECT '', ''+REPLACE(CAST(('+ ValueColumn +') AS VARCHAR(MAX)),''.'', '','')'
						WHEN @REFNAME='Training.TrainingSubject'
						THEN
							'SELECT '', ''+REPLACE(CAST(('+ ValueColumn +') AS VARCHAR(MAX)),'','', '',.'')'
						ELSE
							'SELECT '', ''+CAST(('+ ValueColumn +') AS VARCHAR(MAX))'
						END
						+
			'FROM '+@REFNAME+'
									WHERE '+IDColumn+' IN (SELECT CAST(NSI.SetItem AS NVARCHAR(256))
															FROM dbo.NamedSetsItems NSI
															WHERE NSI.SetId=NS.SetId)
									FOR XML PATH(''''), TYPE) AS VARCHAR(MAX)), 1, 2, '''')
							) AS ''ItemList''
							FROM dbo.NamedSets NS
							WHERE RefName='''+@REFNAME+''''
		FROM dbo.RefColumnMeta RCM
		LEFT JOIN dbo.NamedSets NS ON RCM.RefName=NS.RefName
		WHERE RCM.RefName = @REFNAME;

		--PRINT(@VALUE_TYPE)
		PRINT @SQL
		EXEC (@SQL)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[NAMED_SET_SELECT] TO rl_named_sets_r;
GO
