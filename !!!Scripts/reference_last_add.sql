--WITH EXECUTE AS OWNER

DECLARE @SQL		NVARCHAR(MAX)
DECLARE @REF		NVARCHAR(30)
DECLARE @REF_LAST	NVARCHAR(40)


SET @REF = 'Common.Period' --�������� ������� �� ������������
SET @REF_LAST = 'LAST' --�������� ���� last � �������
SET @SQL =
'
	IF NOT EXISTS(
					SELECT *
					FROM Common.ReferenceLast
					WHERE ReferenceName = '''+@REF+'''
					)
		BEGIN
			INSERT INTO Common.ReferenceLast(ReferenceName, Last)				-- ���� � ������� ����������� ���, �� ��������							
			VALUES ('''+@REF+''', GETDATE())

			UPDATE Common.ReferenceLast 
			SET [Last] = b.'+@REF_LAST+'
			FROM '+@REF+' b
			WHERE ReferenceName = '''+@REF+'''
		END'

EXEC(@SQL)
SET @SQL ='
	CREATE TRIGGER '+@REF+'_INSERT
	ON '+@REF+'
	AFTER INSERT
	AS
	UPDATE Common.ReferenceLast
	SET Last = GETDATE()
	WHERE ReferenceName = '''+@REF+'''
'
EXEC(@SQL)
SET @SQL ='

	CREATE TRIGGER '+@REF+'_UPDATE
	ON '+@REF+'
	AFTER UPDATE
	AS
	UPDATE Common.ReferenceLast
	SET Last = GETDATE()
	WHERE ReferenceName = '''+@REF+'''
'
EXEC(@SQL)
SET @SQL ='

	CREATE TRIGGER '+@REF+'_DELETE
	ON '+@REF+'
	AFTER DELETE
	AS
	UPDATE Common.ReferenceLast
	SET Last = GETDATE()
	WHERE ReferenceName = '''+@REF+'''
'

--PRINT(@SQL)
EXEC(@SQL)