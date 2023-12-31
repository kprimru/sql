USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GET_DISTR_STR]
(
    --27.01.09 �������� �������� �������.
    @sys varchar(20),
	@distr int,
    @comp int
)
RETURNS varchar(30)
AS
BEGIN
	DECLARE @resstr varchar(30)

    IF @sys IS NULL
      SET @resstr = ''
    ELSE
      SET @resstr = @sys + ' '

    SET @resstr = @resstr + Convert(varchar, @distr)

    IF @comp <> 1
      SET @resstr = @resstr + '/' + Convert(varchar, @comp)

    RETURN  @resstr
END
GO
