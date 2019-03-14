USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[USER_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		US_ID_MASTER, US_ID, US_NAME, US_LOGIN, 
		US_NOTE, US_DATE, US_END, 
		create_date AS US_CREATE_DATE, modify_date AS US_MODIFY_DATE
	FROM 
		Security.UserActive LEFT OUTER JOIN
		(
			SELECT [name], create_date, modify_date
			FROM sys.database_principals 
			WHERE [type] IN ('U', 'S')
		) AS o_O ON [name] = US_LOGIN
	
	SELECT @RC = @@ROWCOUNT
END
