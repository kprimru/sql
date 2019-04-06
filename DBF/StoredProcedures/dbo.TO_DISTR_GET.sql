USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[TO_DISTR_GET]
	@tdid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @td TABLE
		(
			TD_ID INT
		)

	INSERT INTO @td
		SELECT *
		FROM dbo.GET_TABLE_FROM_LIST(@tdid, ',')

	DECLARE @dislist VARCHAR(MAX)
	SET @dislist = ''

	SELECT @dislist = @dislist + DIS_STR + ','
	FROM dbo.TODistrView
	WHERE TD_ID IN
		(
			SELECT TD_ID
			FROM @td
		)

	IF LEN(@dislist) > 0
		SET @dislist = LEFT(@dislist, LEN(@dislist) - 1)	

	SELECT @dislist AS DIS_STR
END