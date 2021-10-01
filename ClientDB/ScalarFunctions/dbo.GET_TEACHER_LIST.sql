USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[GET_TEACHER_LIST]
(
	@pbegindate SMALLDATETIME,
	@penddate SMALLDATETIME,
	@clientid INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @resstr VARCHAR(MAX)

	SET @resstr = ''

	SELECT @resstr = @resstr + TeacherName + ',  '
	FROM
		(
			SELECT DISTINCT TeacherName
			FROM
				dbo.TeacherTable a
				INNER JOIN dbo.ClientStudy b ON b.ID_TEACHER = a.TeacherID
				INNER JOIN dbo.ClientTable c ON b.ID_CLIENT = c.ClientID
			WHERE c.ClientID = @clientid
				AND DATE BETWEEN @pbegindate AND @penddate
				AND c.STATUS = 1
				AND b.STATUS = 1
			) AS dt
	ORDER BY TeacherName

	IF LEN(@resstr) > 1
		SET @resstr = LEFT(@resstr, LEN(@resstr) - 1)

	RETURN @resstr
END
GO
