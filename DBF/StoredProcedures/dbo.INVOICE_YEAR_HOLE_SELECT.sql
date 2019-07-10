USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/
CREATE PROCEDURE [dbo].[INVOICE_YEAR_HOLE_SELECT]
	@year VARCHAR(5),
	@orgid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @min BIGINT
	DECLARE @max BIGINT
	DECLARE @row BIGINT

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	CREATE TABLE #temp
		(
			INS_NUM BIGINT
		)

	SELECT @min = MIN(INS_NUM), @max = MAX(INS_NUM) 
	FROM dbo.InvoiceSaleTable
	WHERE INS_NUM_YEAR = @year AND INS_ID_ORG = @orgid

	SELECT @row = @min + 1

	WHILE @row < @max
	BEGIN
		INSERT INTO #temp SELECT @row
		SET @row = @row + 1 
	END
	/*
	SELECT @year, INS_NUM, @orgid
	FROM #temp a EXCEPT 
		SELECT @year, INS_NUM, @orgid
		FROM dbo.InvoiceSaleTable
		WHERE INS_ID_ORG = @orgid
		*/
		
	SELECT @year, INS_NUM, @orgid
	FROM #temp a
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.InvoiceSaleTable b
			WHERE INS_ID_ORG = @orgid
				AND b.INS_NUM = a.INS_NUM
				AND INS_NUM_YEAR = @year
		)

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp
END