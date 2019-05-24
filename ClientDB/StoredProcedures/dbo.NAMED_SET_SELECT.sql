USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NAMED_SET_SELECT]
	@REFNAME	NVARCHAR(128)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @SQL		NVARCHAR(MAX)
	DECLARE @VALUE_TYPE	NVARCHAR(20)

	SELECT @VALUE_TYPE=DATA_TYPE
	FROM information_schema.COLUMNS
	WHERE TABLE_SCHEMA=LEFT(@REFNAME, CHARINDEX('.', @REFNAME)-1)
		AND TABLE_NAME=RIGHT(@REFNAME, (LEN(@REFNAME)-CHARINDEX('.', @REFNAME)))
		AND COLUMN_NAME=(	SELECT ValueColumn
							FROM dbo.RefColumnMeta
							WHERE RefName=@REFNAME)

	SELECT @SQL='SELECT
					SetName,
					(SELECT STUFF(CAST(('
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
	FROM 
		dbo.NamedSets NS
		INNER JOIN dbo.RefColumnMeta RCM ON RCM.RefName=NS.RefName
	WHERE
		NS.RefName=@REFNAME

	--PRINT(@VALUE_TYPE)
	--PRINT @SQL
	EXEC (@SQL)
END
