USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GET_RECOMEND_LIST]
(
	@pbegindate varchar(20),
    @penddate varchar(20),
    @clientid int
)
RETURNS varchar(MAX)
AS
BEGIN	
   DECLARE @resstr varchar(MAX)
   
   SET @resstr = ''

   SELECT @resstr = @resstr + RECOMEND + ',  '
   FROM
        (
          SELECT DISTINCT RECOMEND
          FROM dbo.ClientStudy b 
          WHERE b.ID_CLIENT = @clientid AND DATE BETWEEN @pbegindate AND @penddate  AND STATUS = 1
			AND LTRIM(RTRIM(ISNULL(Recomend, ''))) <> ''
        ) AS dt 

   IF LEN(@resstr) > 1 
     SET @resstr = LEFT(@resstr, LEN(@resstr) - 1)

   RETURN @resstr

END