USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_STUDENT_LIST_EX]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_STUDENT_LIST_EX] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [dbo].[GET_STUDENT_LIST_EX]
(
	@pbegindate SMALLDATETIME,
    @penddate SMALLDATETIME,
    @clientid int,
	@teacher bit,
	@student bit
)
RETURNS varchar(MAX)
AS
BEGIN



   DECLARE @resstr varchar(MAX)

   SET @resstr = ''

	DECLARE @TBL TABLE (POS_ID VARCHAR(150))

		IF @teacher = 1
			INSERT INTO @TBL(POS_ID)
				SELECT 'Преподаватель'
		IF @student = 1
			INSERT INTO @TBL(POS_ID)
				SELECT 'Студент'

   SELECT @resstr = @resstr + SURNAME + ' ' + NAME + ' ' + PATRON + ',  '
   FROM
        (
          SELECT DISTINCT SURNAME, NAME, PATRON
          FROM dbo.ClientStudy b INNER JOIN
               dbo.ClientStudyPeople c ON b.ID = c.ID_STUDY INNER JOIN
				@TBL ON POS_ID = c.POSITION
          WHERE b.ID_CLIENT = @clientid
			AND DATE BETWEEN @pbegindate AND @penddate 
			AND STATUS = 1
        ) AS dt
   ORDER BY SURNAME, NAME, PATRON

   IF LEN(@resstr) > 1
     SET @resstr = LEFT(@resstr, LEN(@resstr) - 1)

   RETURN @resstr

END
GO
