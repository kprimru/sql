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
CREATE PROCEDURE [dbo].[ACT_ALL_PRINT]
	@actdate SMALLDATETIME,
	@cour VARCHAR(MAX),
	@check BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#actcour') IS NOT NULL
		DROP TABLE #actcour
	
	CREATE TABLE #actcour
		(
			COUR_ID SMALLINT
		)

	IF @cour IS NULL
		INSERT INTO #actcour
			SELECT COUR_ID
			FROM dbo.CourierTable
	ELSE
	INSERT INTO #actcour
		SELECT *
		FROM dbo.GET_TABLE_FROM_LIST(@cour, ',')


	DECLARE @actlist VARCHAR(MAX)

	SET @actlist = ''

	SELECT @actlist = @actlist + CONVERT(VARCHAR(10), ACT_ID) + ','
	FROM 
		(
			SELECT DISTINCT ACT_ID
			FROM
				dbo.ActTable INNER JOIN
				dbo.ClientTable ON ACT_ID_CLIENT = CL_ID INNER JOIN
				dbo.TOTable ON TO_ID_CLIENT = CL_ID INNER JOIN
				#actcour ON COUR_ID = TO_ID_COUR
			WHERE ACT_DATE = @actdate
				AND (ACT_PRINT IS NULL OR ACT_PRINT = 0)
		) AS o_O
		
	

	IF LEN(@actlist) > 2
		SET @actlist = LEFT(@actlist, LEN(@actlist) - 1)

	IF OBJECT_ID('tempdb..#actcour') IS NOT NULL
		DROP TABLE #actcour

	IF @check = 1
		EXEC dbo.ACT_PRINT_BY_ID_LIST @actlist, 0
	ELSE
		EXEC dbo.ACT_PRINT_BY_ID_LIST @actlist, 1

	IF @check = 1
	BEGIN
		DECLARE @adate DATETIME
		SET @adate = GETDATE()

		UPDATE dbo.ActTable
		SET ACT_PRINT = 1,
			ACT_PRINT_DATE = @adate
		WHERE ACT_ID IN
			(
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@actlist, ',')
			)
	END

	IF OBJECT_ID('tempdb..#actcour') IS NOT NULL
		DROP TABLE #actcour
END