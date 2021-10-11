USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[_GET_SYS_BY_SYM]
(
  @sname VARCHAR(20)
)
RETURNS INT
AS
BEGIN
  DECLARE @res INT

  IF @sname = 'P'
    SET @res = 1
  ELSE IF @sname = 'E'
    SET @res = 2
  ELSE IF @sname = 'C'
    SET @res = 3
  ELSE IF @sname = 'R'
    SET @res = 4
  ELSE IF @sname = 'L'
    SET @res = 5
  ELSE IF @sname = 'M'
    SET @res = 6
  ELSE IF @sname = 'B'
    SET @res = 7
  ELSE IF @sname = 'Q'
    SET @res = 8
  ELSE IF @sname = 'F'
    SET @res = 9
  ELSE IF @sname = 'O'
    SET @res = 10
  ELSE IF @sname = 'H'
    SET @res = 11
  ELSE IF @sname = 'K'
    SET @res = 12
  ELSE IF @sname = '8'
    SET @res = 13
  ELSE IF @sname = 'A'
    SET @res = 14
  ELSE IF @sname = '0'
    SET @res = 15
  ELSE IF @sname = '1'
    SET @res = 16
  ELSE IF @sname = '2'
    SET @res = 17
  ELSE IF @sname = '3'
    SET @res = 18
  ELSE IF @sname = '9'
    SET @res = 19
  ELSE IF @sname = 'D'
    SET @res = 20
  ELSE IF @sname = 'I'
    SET @res = 21
  ELSE IF @sname = 'G'
    SET @res = 22
  ELSE IF @sname = 'Z'
    SET @res = 23
  ELSE IF @sname = 'J'
    SET @res = 24
  ELSE IF @sname = 'U'
    SET @res = 25
  ELSE IF @sname = 'T'
    SET @res = 26
  ELSE IF @sname = 'N'
    SET @res = 27
  ELSE IF @sname = 'Y'
    SET @res = 28
  ELSE IF @sname = 'V'
    SET @res = 29
  ELSE IF @sname = 'W'
    SET @res = 30
  ELSE IF @sname = 'X'
    SET @res = 31
  ELSE IF @sname = '7'
    SET @res = 32
  ELSE IF @sname = '6'
    SET @res = 33

  RETURN @res
END

GO
