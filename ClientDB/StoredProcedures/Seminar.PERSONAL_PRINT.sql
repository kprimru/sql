USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[PERSONAL_PRINT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		ROW_NUMBER() OVER (ORDER BY a.ClientFullName, SURNAME, NAME, PATRON) AS RN,
		a.ClientFullName, FIO,
		POSITION, PHONE, a.ServiceName, ManagerName,
		NOTE, CASE ISNULL(NOTE, '') WHEN '' THEN 0 ELSE 1 END AS NOTE_EXISTS
	FROM
		dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN Seminar.PersonalView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
	WHERE ID_SCHEDULE = @ID AND INDX = 1
	ORDER BY a.ClientFullName, FIO
END