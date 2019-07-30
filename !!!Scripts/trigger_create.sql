DECLARE @schema	NVARCHAR(20)
DECLARE @name	NVARCHAR(30)
DECLARE	@SQL	NVARCHAR(MAX)

DECLARE cur CURSOR FOR
	SELECT ReferenceSchema, ReferenceName
	FROM Common.Reference

OPEN cur

FETCH NEXT FROM cur
INTO @schema, @name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = '
		CREATE TRIGGER [' + @schema + '.' + @name + '_LAST_UPDATE]
		ON ' + @schema + '.' + @name + '
		AFTER INSERT, UPDATE, DELETE
		AS
			UPDATE Common.Reference
			SET ReferenceLast = GETDATE()
			WHERE ReferenceName = ''' + @name + ''' AND ReferenceSchema = ''' + @schema + ''''
	--PRINT(@SQL)
	EXEC(@SQL)

	FETCH NEXT FROM cur
	INTO @schema, @name
END

CLOSE cur
DEALLOCATE cur

SELECT * FROM sys.triggers ORDER BY name