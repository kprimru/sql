USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_CLIENT_LIST_BY_STUDY_DATE_NEW]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_CLIENT_LIST_BY_STUDY_DATE_NEW] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[GET_CLIENT_LIST_BY_STUDY_DATE_NEW]
(
	@pbegindate SMALLDATETIME,
	@penddate SMALLDATETIME,
	@serviceid INT,
	@statusid INT = null,
	@TEACHER NVARCHAR(MAX) = NULL
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
				INNER JOIN dbo.ClientStudy c ON c.ID_CLIENT = b.CLientID 
			WHERE ServiceID = @serviceid
				AND c.DATE BETWEEN @pbegindate AND @penddate
				AND c.TEACHED = 1
				AND c.STATUS = 1
				and (StatusID = @statusid or @statusid IS NULL)
				AND b.STATUS = 1
				AND (ID_TEACHER IN (SELECT ID FROM dbo.TableIDFromXML(@TEACHER)) OR @TEACHER IS NULL)
		) AS dt
	ORDER BY ClientFullName

	IF LEN(@resstr) > 1
		SET @resstr = LEFT(@resstr, LEN(@resstr) - 1)

	RETURN @resstr
END
GO
