USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GET_DISTR_BY_ID]
(
	@distrid int
)
RETURNS varchar(30)
AS
BEGIN
	DECLARE @resstr varchar(30)

    SELECT @resstr = dbo.GET_DISTR_STR(SYS_ID, DIS_NUM, DIS_COMP_NUM)
    FROM dbo.DistrTable a INNER JOIN
         dbo.SystemTable b ON a.DIS_ID_SYSTEM = b.SYS_ID
    WHERE DIS_ID = @distrid

    RETURN  @resstr
END
GO
