USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_STUDENT_LIST]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_STUDENT_LIST] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[GET_STUDENT_LIST]
(
	@pbegindate SMALLDATETIME,
    @penddate SMALLDATETIME,
    @clientid int
)
RETURNS varchar(MAX)
AS
BEGIN
   DECLARE @resstr varchar(MAX)

   SET @resstr = ''

   SELECT @resstr = @resstr + SURNAME + ' ' + NAME + ' ' + PATRON + ',  '
   FROM
        (
          SELECT DISTINCT SURNAME, NAME, PATRON
          FROM dbo.ClientStudy b INNER JOIN
               dbo.ClientStudyPeople c ON b.ID = c.ID_STUDY
          WHERE b.ID_CLIENT = @clientid AND DATE BETWEEN @pbegindate AND @penddate           AND STATUS = 1
        ) AS dt
   ORDER BY SURNAME, NAME, PATRON

   IF LEN(@resstr) > 1
     SET @resstr = LEFT(@resstr, LEN(@resstr) - 1)

   RETURN @resstr

END
GO
