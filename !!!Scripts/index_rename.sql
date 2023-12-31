DECLARE @chngmode BIT

SET @chngmode = 1 --��� ��� ������, ������ �������� � ������� - 0, ������������� - 1

DECLARE @diff TABLE
(
	[oldname] VARCHAR(128),
	[newname] VARCHAR(128)
);


---------------------------------------------*************************�������*************************---------------------------------------------

DECLARE cur CURSOR
FOR
SELECT
	sch.name AS [schema], t.name AS [table], i.name AS [index],
	CASE
		WHEN i.type_desc = 'NONCLUSTERED'	AND i.is_unique = 0	THEN 'IX_'
		WHEN i.type_desc = 'NONCLUSTERED'	AND i.is_unique = 1	THEN 'UX_'
		WHEN i.type_desc = 'CLUSTERED'		AND i.is_unique = 0	THEN 'IC_'
		WHEN i.type_desc = 'CLUSTERED'		AND i.is_unique = 1	THEN 'UC_'
		ELSE NULL
	END + sch.name + '.' + t.name + '(' + mc.Columns + ')' + 
	CASE	
		WHEN ic.IncludedColumns IS NOT NULL THEN '+(' + ic.IncludedColumns + ')'
		ELSE ''
	END AS [right name]
FROM
	sys.indexes i
	INNER JOIN
	(
		SELECT schema_id, object_id, name
		FROM sys.tables
		
		UNION
		
		SELECT schema_id, object_id, name
		FROM sys.views
	) t ON i.object_id = t.object_id
	INNER JOIN sys.schemas sch ON sch.schema_id = t.schema_id
	OUTER APPLY
	(
		SELECT [Columns] = STUFF(
			(
				SELECT ',' + c.name 
				FROM sys.columns				c
				INNER JOIN sys.index_columns	ic ON c.column_id = ic.column_id
				WHERE t.object_id = c.object_id
					AND ic.index_id = i.index_id
					AND t.object_id = ic.object_id
					AND ic.is_included_column = 0
				ORDER BY ic.key_ordinal FOR XML PATH('')
			),1,1,'')
	) AS mc
	OUTER APPLY
	(
		SELECT [IncludedColumns] = STUFF(
			(
				SELECT ',' + c.name 
				FROM sys.columns				c
				INNER JOIN sys.index_columns	ic ON c.column_id = ic.column_id
				WHERE t.object_id = c.object_id
					AND ic.index_id = i.index_id
					AND t.object_id = ic.object_id
					AND ic.is_included_column = 1
				ORDER BY ic.key_ordinal FOR XML PATH('')
			),1,1,'')
	) AS ic
WHERE	is_primary_key = 0
	AND is_unique_constraint = 0
	AND i.type_desc <> 'HEAP'
ORDER BY 
	'schema', 'table', 'index'

OPEN cur 

DECLARE @err int
DECLARE @counter int
DECLARE @schema NVARCHAR(20), @table NVARCHAR(150), @index NVARCHAR(MAX), @index_name NVARCHAR(MAX), @index_right NVARCHAR(MAX)

SET @err = 0
SET @counter = 0
SET @schema=''
SET @table=''
SET @index=''
SET @index_name=''
SET @index_right=''

FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @index_name = '[' + @schema + '].[' + @table + '].[' + @index + ']';
	IF LEN(@index_right)>100
	BEGIN TRY
		SET @index_right = SUBSTRING(@index_right, 1, CHARINDEX('+', @index_right)-1)+'+INCL'--���� �������� ������� �������, �� ������� ����� � INCLUDED
	END TRY
	BEGIN CATCH
		SET @index_right = SUBSTRING(@index_right, 1, CHARINDEX('(', @index_right)-1)+'+COL+INCL'--���� ���� ������ ������� �� � �������
	END CATCH
	IF LEN(@index_right)>100
	BEGIN
		PRINT '������ '+@index+' �� ��� ������������, ��� ��� ��������������� ��� ������� �������' -- ���� � ����� ����� ������� �������, ����� ������ �� ������
		SET @err = @err + 1
		FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
		CONTINUE
	END
	IF (@index <> @index_right)AND(@chngmode=1)
	BEGIN TRY
		--PRINT ('EXEC sp_rename ''' + @index_name + ''', ''' + @index_right + ''', N''INDEX'';');
		EXEC sp_rename @index_name, @index_right, N'INDEX'
	END TRY
	BEGIN CATCH
		SET @err = @err + 1 
		PRINT @index
		PRINT ERROR_MESSAGE()
	END CATCH
	ELSE IF (@index <> @index_right) AND(@chngmode=0)
	BEGIN
		INSERT INTO @diff([oldname],[newname]) VALUES(@index, @index_right)
	END
	SET @counter = @counter + 1
	FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
END

IF @err = 0
	PRINT '������ indexes ��� �������� ��� ������'
ELSE
	PRINT '������ indexes �������� � �������� ('+CONVERT(NVARCHAR, @err)+')'
	
CLOSE cur
DEALLOCATE cur



---------------------------------------------*************************��������� �����*************************---------------------------------------------



DECLARE cur CURSOR
FOR 
SELECT
	sch.name AS 'schema', t.name AS 'table', kc.name AS 'index',
	'PK_'+sch.name+'.'+t.name AS 'right name'
FROM
	sys.key_constraints kc
	INNER JOIN sys.tables t ON kc.parent_object_id=t.object_id
	INNER JOIN sys.schemas sch ON sch.schema_id=kc.schema_id
	INNER JOIN sys.indexes ic ON kc.name=ic.name
WHERE
	kc.type='PK'
ORDER BY
	'schema', 'table', 'index'

OPEN cur

SET @err = 0
SET @counter = 0

FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @index_name = '[' + @schema+'].['+@table+'].['+@index + ']'
	IF LEN(@index_right)>100
	BEGIN
		PRINT '������ '+@index+' �� ��� ������������, ��� ��� ��������������� ��� ������� �������' -- ���� � ����� ����� ������� �������, ����� ������ �� ������
		FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
		CONTINUE
	END
	IF (@index <> @index_right)AND(@index<>'pk_dtproperties')AND(@chngmode=1) -- ��������� ��� � ������� ��������� ���������� PK
	BEGIN TRY
		EXEC sp_rename @index_name, @index_right
	END TRY
	BEGIN CATCH
		SET @err = @err + 1 
		PRINT @index
		PRINT ERROR_MESSAGE()
	END CATCH
	ELSE IF ((@index <> @index_right)AND(@index<>'pk_dtproperties')AND(@chngmode=0))
	BEGIN
		INSERT INTO @diff([oldname],[newname]) VALUES(@index, @index_right)
	END
	SET @counter = @counter + 1
	FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
END

IF @err = 0
	PRINT '������ PK ��� �������� ��� ������'
ELSE
	PRINT '������ PK �������� � �������� ('+CONVERT(NVARCHAR, @err)+')'

CLOSE cur
DEALLOCATE cur


---------------------------------------------*************************���������� �����������*************************---------------------------------------------


DECLARE cur CURSOR
FOR 
SELECT
	sch.name AS 'schema', t.name AS 'table', kc.name AS 'index',
	'UQ_'+sch.name+'.'+t.name+'('+')' AS 'right name'
FROM
	sys.key_constraints kc
	INNER JOIN sys.tables t ON kc.parent_object_id=t.object_id
	INNER JOIN sys.schemas sch ON sch.schema_id=kc.schema_id
WHERE
	kc.type='UQ'

OPEN cur

SET @err = 0
SET @counter = 0

FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @index_name = @schema+'.'+@table+'.'+@index
	IF LEN(@index_right)>100
	BEGIN
		PRINT '������ '+@index+' �� ��� ������������, ��� ��� ��������������� ��� ������� �������' -- ���� � ����� ����� ������� �������, ����� ������ �� ������
		FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
		CONTINUE
	END
	IF (@index <> @index_right)AND(@index<>'UK_principal_name')AND(@chngmode=1) -- ��������� ��� � ������� ��������� ���������� UK
	BEGIN TRY
		EXEC sp_rename @index_name, @index_right
	END TRY
	BEGIN CATCH
		SET @err = @err + 1 
		PRINT @index
		PRINT ERROR_MESSAGE()
	END CATCH
	ELSE IF (@index <> @index_right)AND(@index<>'UK_principal_name')AND(@chngmode=0)
	BEGIN
		INSERT INTO @diff([oldname],[newname]) VALUES(@index, @index_right)
	END
	SET @counter = @counter + 1
	FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
END

IF @err = 0
	PRINT '������ UK ��� �������� ��� ������'
ELSE
	PRINT '������ UK �������� � �������� ('+CONVERT(NVARCHAR, @err)+')'

CLOSE cur
DEALLOCATE cur


---------------------------------------------*************************������� �����*************************---------------------------------------------


DECLARE cur CURSOR
FOR
SELECT
	sch.name AS 'schema', t.name AS 'table', fk.name AS 'index', 'FK_'+sch.name+'.'+t.name+'('+c.name+')_'+schr.name+'.'+tr.name+'('+cr.name+')' AS 'right name'
FROM
	sys.foreign_keys fk
	INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
	INNER JOIN sys.tables t ON fk.parent_object_id=t.object_id
	INNER JOIN sys.tables tr ON fk.referenced_object_id=tr.object_id
	INNER JOIN sys.schemas sch ON sch.schema_id=t.schema_id
	INNER JOIN sys.schemas schr ON schr.schema_id=t.schema_id
	INNER JOIN sys.columns c ON c.column_id=fkc.parent_column_id AND t.object_id=c.object_id
	INNER JOIN sys.columns cr ON cr.column_id=fkc.referenced_column_id AND tr.object_id=cr.object_id
ORDER BY 
	'schema', 'table', 'index'

OPEN cur 

DECLARE @sym_pos INT
DECLARE @copy_num INT

SET @err = 0
SET @counter = 0
SET @schema=''
SET @table=''
SET @index=''
SET @index_name=''
SET @index_right=''
SET @copy_num = 1

FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @index_name = '[' + @schema+'].['+@index + ']'
	IF (LEN(@index_right)>100)AND((LEN(@index_right)-LEN(REPLACE(@index_right, CHAR(40), ''))) = 2)   -- ������ ���� - ��� ���������� ����������� ������ � ������ (����� �� ���� ����, ��� ������� ����)
	BEGIN 
		SET @index_right = REVERSE (@index_right)
		SET @index_right = SUBSTRING (@index_right, CHARINDEX('(', @index_right)+1, LEN(@index_right))-- ���� ������� �������, �� �������� ����� �� ��������� ������ �������
		SET @index_right = REVERSE (@index_right)													  -- ����� ����� ���� ���, ���� � ������ ������ �� ������ ������ �� 
	END																								  -- ��������� ������ �������, ����� ������� ������� ������ ������� � ��� ��� ������
	IF LEN(@index_right)>100
	BEGIN
		SET @index_right = REVERSE (@index_right)
		SET @sym_pos = CHARINDEX(CHAR(95), @index_right)-1
		SET @index_right = SUBSTRING (@index_right, 1, @sym_pos)
		SET @index_right = REVERSE (@index_right)
	END
	/*IF (LEN(@index_right)>100)
	BEGIN
		SET @sym_pos = CHARINDEX(CHAR(40), @index_right)-1
		SET @index_right = REVERSE (@index_right)                                                     --�������, ����� �������� ��������� ������ � �� ������
		SET @index_right = SUBSTRING (@index_right, 1, @sym_pos)
		SET @index_right = REVERSE (@index_right)											  
	END		
	IF LEN(@index_right)>100
	BEGIN
		PRINT '������ '+@index+' �� ��� ������������, ��� ��� ��������������� ��� ������� �������'    -- ���� � ����� ����� ������� �������, ����� ������ �� ������
		SET @err = @err + 1
		FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
		CONTINUE
	END*/
	IF (NOT (@index LIKE @index_right+'%'))AND(@chngmode=1)														  -- �
	BEGIN TRY
		EXEC sp_rename @index_name, @index_right, N'OBJECT'
		SET @copy_num = 1
	END TRY
	BEGIN CATCH
		IF ERROR_NUMBER() = 15335
		BEGIN
			IF	SUBSTRING(@index_right, LEN(@index_right), 1) = '1' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '2' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '3' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '4' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '5' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '6' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '7' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '8' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '9' OR
				SUBSTRING(@index_right, LEN(@index_right), 1) = '0'
			BEGIN
				SET @copy_num = CONVERT(INT, SUBSTRING(REVERSE(@index_right), 1, 1))
				SET @index_right = SUBSTRING(@index_right, 1, LEN(@index_right)-1)+ CONVERT(NVARCHAR, @copy_num+1)
				PRINT(@index_right)
				CONTINUE
			END
			ELSE
			BEGIN
				SET @index_right = @index_right + '1'
				CONTINUE
			END
		END
		SET @err = @err + 1 
		PRINT @index
		PRINT ERROR_MESSAGE()
		PRINT ERROR_NUMBER()
	END CATCH
	ELSE IF (NOT (@index LIKE @index_right+'%'))AND(@chngmode=0)
	BEGIN
		INSERT INTO @diff([oldname],[newname]) VALUES(@index, @index_right)
	END
	SET @counter = @counter + 1
	FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
END

IF @chngmode=0
BEGIN
	SELECT * FROM @diff
END

IF @err = 0
	PRINT '������ FK ��� �������� ��� ������'
ELSE
	PRINT '������ FK �������� � �������� ('+CONVERT(NVARCHAR, @err)+')'
	
CLOSE cur
DEALLOCATE cur



---------------------------------------------*************************DEFAULTS*************************---------------------------------------------

DECLARE cur CURSOR
FOR 
SELECT
	sch.name AS 'schema', t.name AS 'table', sch.name + '.[' + kc.name + ']' AS 'index',
	'DF_'+sch.name+'.'+t.name + '(' + c.name + ')' AS 'right name'
FROM
	sys.default_constraints kc
	INNER JOIN sys.tables t ON kc.parent_object_id=t.object_id
	INNER JOIN sys.schemas sch ON sch.schema_id=kc.schema_id
	INNER JOIN sys.columns c ON c.object_id = t.object_id AND c.column_id = kc.parent_column_id
WHERE
	kc.type='D'
ORDER BY
	'schema', 'table', 'index'

OPEN cur

SET @err = 0
SET @counter = 0

FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @index_name = @index
	IF LEN(@index_right)>100
	BEGIN
		PRINT '������ '+@index+' �� ��� ������������, ��� ��� ��������������� ��� ������� �������' -- ���� � ����� ����� ������� �������, ����� ������ �� ������
		FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
		CONTINUE
	END
	IF (@index <> @index_right)AND(@index<>'pk_dtproperties')AND(@chngmode=1) -- ��������� ��� � ������� ��������� ���������� PK
	BEGIN TRY
		EXEC sp_rename @index_name, @index_right
	END TRY
	BEGIN CATCH
		SET @err = @err + 1 
		PRINT @index
		PRINT ERROR_MESSAGE()
	END CATCH
	ELSE IF ((@index <> @index_right)AND(@index<>'pk_dtproperties')AND(@chngmode=0))
	BEGIN
		INSERT INTO @diff([oldname],[newname]) VALUES(@index, @index_right)
	END
	SET @counter = @counter + 1
	FETCH NEXT FROM cur INTO @schema, @table, @index, @index_right
END

IF @err = 0
	PRINT '������ DF ��� �������� ��� ������'
ELSE
	PRINT '������ DF �������� � �������� ('+CONVERT(NVARCHAR, @err)+')'

CLOSE cur
DEALLOCATE cur