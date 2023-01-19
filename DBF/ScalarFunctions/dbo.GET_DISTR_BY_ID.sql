USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_DISTR_BY_ID]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_DISTR_BY_ID] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[GET_DISTR_BY_ID]
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
