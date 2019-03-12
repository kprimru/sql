USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [dbo].[GET_CLIENT_LIST_BY_STUDY_DATE]
(
	@pbegindate SMALLDATETIME,
	@penddate SMALLDATETIME,
	@serviceid int
)
RETURNS varchar(MAX)
AS
BEGIN	
	DECLARE @resstr varchar(250)
   
	SET @resstr = ''

	SELECT @resstr = @resstr + ClientFullName + ', '
	FROM
        (
			SELECT DISTINCT ClientFullName
			FROM 
				dbo.ServiceTable a 
				INNER JOIN dbo.ClientTable b ON a.ServiceID = b.ClientServiceID 
				INNER JOIN dbo.StudyTable c ON c.ClientID = b.CLientID
			WHERE b.STATUS = 1
				AND ServiceID = @serviceid 
				AND StudyDate BETWEEN @pbegindate AND @penddate
		) AS dt 
	ORDER BY ClientFullName

	IF LEN(@resstr) > 1 
		SET @resstr = LEFT(@resstr, LEN(@resstr) - 1)

	RETURN @resstr
END