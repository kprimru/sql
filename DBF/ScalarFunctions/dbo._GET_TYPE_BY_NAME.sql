USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
CREATE FUNCTION _GET_TYPE_BY_NAME
(
  @tname VARCHAR(20)
)
RETURNS INT
AS
BEGIN
  DECLARE @res INT

  IF @tname = '���' 
    SET @res = 1
  ELSE IF @tname = '�.�'
    SET @res = 2
  ELSE IF @tname = '�/�'
    SET @res = 3
  ELSE IF @tname = '' OR @tname IS NULL
    SET @res = 4
  ELSE IF @tname = '�.�'
    SET @res = 5
  ELSE IF @tname = '�/�'
    SET @res = 6
  ELSE IF @tname = 'VIP'
    SET @res = 7
  ELSE IF @tname = '�.�'
    SET @res = 8
  ELSE IF @tname = '��'
    SET @res = 9
  ELSE IF @tname = '�.�'
    SET @res = 10
  
  RETURN @res
END
