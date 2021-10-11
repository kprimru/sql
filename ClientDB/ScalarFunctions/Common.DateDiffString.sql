USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Common].[DateDiffString]
(
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
)
RETURNS NVARCHAR(128)
AS
BEGIN
	DECLARE @RES NVARCHAR(128)

	SET @RES = ''

	DECLARE @YEAR SMALLINT
	DECLARE @MONTH SMALLINT
	DECLARE @DAY SMALLINT

	SET @YEAR = DATEDIFF(MONTH, @BEGIN, @END) / 12

	IF @YEAR > 0
		SET @RES = @RES + CONVERT(NVARCHAR(64), @YEAR) + ' ' + CASE WHEN @YEAR = 1 THEN '���' WHEN @YEAR > 1 AND @YEAR <= 4 THEN '����' ELSE '���' END + ' '

	SET @END = DATEADD(YEAR, -@YEAR, @END)

	SET @MONTH = DATEDIFF(MONTH, @BEGIN, @END) + SIGN(1+SIGN(DAY(@END)-DAY(@BEGIN)))-1;

	IF @MONTH > 0
		SET @RES = @RES + CONVERT(NVARCHAR(64), @MONTH) + ' ' + CASE WHEN @MONTH = 1 THEN '�����' WHEN @MONTH > 1 AND @MONTH <= 4 THEN '������' ELSE '�������' END + ' '

	SET @END = DATEADD(MONTH, -@MONTH, @END)

	SET @DAY = DATEDIFF(DAY, @BEGIN, @END)

	IF @DAY > 0
		SET @RES = @RES + CONVERT(NVARCHAR(64), @DAY) + ' ' + CASE WHEN @DAY = 1 THEN '����' WHEN @DAY > 1 AND @DAY <= 4 THEN '���' ELSE '����' END + ' '

	SET @RES = RTRIM(@RES)

	IF @RES = N''
		SET @RES = N'�������'
	ELSE IF @RES = N'1 ����'
		SET @RES = N'�����'
	ELSE
		SET @RES = @RES + ' �����'

	RETURN @RES
END
GO
