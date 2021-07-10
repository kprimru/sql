USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:		  ������� �������
��������:	  ��������� �������� ����� ���.����
*/
ALTER PROCEDURE [dbo].[REG_NODE_LOAD_LOCAL] 
	@filename VARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	--��� 1. ��������� �� �� ������ � ������ /outcsv
	DECLARE @bcppath VARCHAR(MAX)

	SET @bcppath = dbo.GET_SETTING('BCP_PATH')

	--��� 2. �������� ������ �� ��������� �������

	DECLARE @sql NVARCHAR(4000)

	TRUNCATE TABLE dbo.RegNodeTable

	SET @sql = '
	BULK INSERT dbo.RegNodeTable
	FROM ''' + @filename + '''
	WITH
		(
		FORMATFILE = ''' + @bcppath + ''',
		FIRSTROW = 2
		)'
	--SELECT 1 AS ER_MSG, @sql
	EXEC sp_executesql @sql
	--��� 1. ��������� �� �� ������ � ������ /outcsv

	UPDATE dbo.RegNodeTable
	SET RN_COMMENT = REPLACE(LEFT(RIGHT(RN_COMMENT, LEN(RN_COMMENT) - 1), LEN(RN_COMMENT) - 2), '""', '"')
	WHERE SUBSTRING(RN_COMMENT, 1, 1) = '"' AND SUBSTRING(RN_COMMENT, LEN(RN_COMMENT), 1) = '"'

	SELECT @@ROWCOUNT AS ROW_COUNT 

	EXEC [dbo].[DISTR_BUH_CHANGE]
END
GO
GRANT EXECUTE ON [dbo].[REG_NODE_LOAD_LOCAL] TO rl_reg_node_w;
GO