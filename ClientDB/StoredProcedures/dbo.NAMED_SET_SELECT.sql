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
	DECLARE @SQL	NVARCHAR(MAX)
	SELECT @SQL='SELECT
					SetName,
					(SELECT STUFF(CAST((
							SELECT '', ''+CAST(('+ ValueColumn
										+') AS VARCHAR)
							FROM '+@REFNAME+'
							WHERE '+IDColumn+' IN (SELECT CAST(NSI.SetItem AS NVARCHAR)
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
	--PRINT @SQL
	EXEC (@SQL)
END
