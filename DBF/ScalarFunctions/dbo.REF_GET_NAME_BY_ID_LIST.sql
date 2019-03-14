USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE FUNCTION [dbo].[REF_GET_NAME_BY_ID_LIST]
(
	-- Список параметров функции
	@refname VARCHAR(100),
	@idlist VARCHAR(MAX)
)
-- Тип, который возвращает
RETURNS VARCHAR(MAX)
AS
BEGIN

	-- переменная, в которой будет храниться результат работы функции
	DECLARE @result VARCHAR(MAX)

	IF @idlist IS NULL
		SET @result = NULL
	ELSE
	BEGIN


	-- Текст процедуры ниже
	DECLARE @temp TABLE (ID INT)

	
	DECLARE @tmp TABLE	(DATA_ID INT, DATA_NAME VARCHAR(100))	
	
	IF @refname = 'SYSTEM'
		INSERT INTO @tmp
		SELECT SYS_ID, SYS_SHORT_NAME
		FROM dbo.SystemTable
	ELSE IF @refname = 'SYSTEM_TYPE'
		INSERT INTO @tmp
		SELECT SST_ID, SST_LST
		FROM dbo.SystemTypeTable
	ELSE IF @refname = 'DISTR_SERVICE'
		INSERT INTO @tmp
		SELECT DSS_ID, DSS_NAME
		FROM dbo.DistrServiceStatusTable
	ELSE IF @refname = 'SYSTEM_NET'
		INSERT INTO @tmp
		SELECT SN_ID, SN_NAME
		FROM dbo.SystemNetTable
	ELSE IF @refname = 'SYSTEM_NET_COUNT'
		INSERT INTO @tmp
		SELECT SNC_ID, SNC_NET_COUNT
		FROM dbo.SystemNetCountTable
	ELSE IF @refname = 'PERIOD'
		INSERT INTO @tmp
		SELECT PR_ID, PR_NAME
		FROM dbo.PeriodTable
	ELSE IF @refname = 'SUBHOST'
		INSERT INTO @tmp
		SELECT SH_ID, SH_SHORT_NAME
		FROM dbo.SubhostTable
	ELSE IF @refname = 'TECHNOL_TYPE'
		INSERT INTO @tmp
		SELECT NULL, NULL
	ELSE IF @refname = 'DISTR_STATUS'
		INSERT INTO @tmp
		SELECT DS_ID, DS_NAME
		FROM dbo.DistrStatusTable		
	
	--SELECT * FROM #temp

	--SELECT * FROM #tmp


	/*
	IF @idlist IS NULL
		INSERT INTO @temp SELECT DATA_ID FROM @tmp
	ELSE
	*/
	
	INSERT INTO @temp
		SELECT * FROM dbo.GET_TABLE_FROM_LIST(@idlist, ',')

	SET @result = ''

	SELECT @result = @result + ISNULL(DATA_NAME, '') + ', ' 
	FROM @tmp INNER JOIN 
		@temp ON DATA_ID = ID

	IF LEN(@result) > 2
		SET @result = LEFT(@result, LEN(@result) - 1)	
			
	END
	-- Возвращение результата работы функции
	RETURN @result	
END