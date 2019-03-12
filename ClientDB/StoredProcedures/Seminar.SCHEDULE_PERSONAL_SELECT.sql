USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Seminar].[SCHEDULE_PERSONAL_SELECT]
	@SCHEDULE	UNIQUEIDENTIFIER,
	@CLIENT		NVARCHAR(128),
	@PERSONAL	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE @SUBJECT	UNIQUEIDENTIFIER
	
	SELECT @SUBJECT = ID_SUBJECT
	FROM Seminar.Schedule
	WHERE ID = @SCHEDULE

	SELECT DISTINCT
		a.ID, a.ClientID, CL_RN, PER_RN, ClientFullName, a.FIO, SURNAME, NAME, PATRON, POSITION, PHONE, NOTE, COLOR, a.INDX, UPD_DATE, UPD_USER,
		ServiceName, ServiceStatusIndex, ID_SCHEDULE, CONFIRM_DATE, INVITE_NUM, CONFIRM_STATUS, a.PSEDO, a.EMAIL
	FROM 
		Seminar.PersonalView a WITH(NOEXPAND)
		INNER JOIN
			(
				SELECT ClientID, INDX, ROW_NUMBER() OVER(PARTITION BY INDX ORDER BY ClientFullName) AS CL_RN
				FROM
					(
						SELECT DISTINCT ClientID, ClientFullName, INDX
						FROM Seminar.PersonalView WITH(NOEXPAND)
						WHERE ID_SCHEDULE = @SCHEDULE
							AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
							AND (FIO LIKE @PERSONAL OR @PERSONAL IS NULL)
					) AS o_O
			) AS b ON a.ClientID = b.ClientID AND a.INDX = b.INDX
		INNER JOIN
			(
				SELECT ID, ClientID, INDX, FIO, ROW_NUMBER() OVER(PARTITION BY INDX ORDER BY ClientFullName, FIO, ID) AS PER_RN
				FROM Seminar.PersonalView WITH(NOEXPAND)
				WHERE ID_SCHEDULE = @SCHEDULE
					AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
					AND (FIO LIKE @PERSONAL OR @PERSONAL IS NULL)
			) AS c ON a.ID = c.ID--a.ClientID = c.ClientID AND a.INDX = c.INDX AND a.FIO = c.FIO
	WHERE a.INDX <> 2
		AND ID_SCHEDULE = @SCHEDULE
		AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
		AND (a.FIO LIKE @PERSONAL OR @PERSONAL IS NULL)		
		
	UNION ALL
	
	SELECT DISTINCT
		ID, a.ClientID, CL_RN, PER_RN, ClientFullName, a.FIO, SURNAME, NAME, PATRON, POSITION, PHONE, NOTE, COLOR, a.INDX, UPD_DATE, UPD_USER,
		ServiceName, ServiceStatusIndex, ID_SCHEDULE, CONFIRM_DATE, INVITE_NUM, CONFIRM_STATUS, a.PSEDO, a.EMAIL
	FROM 
		Seminar.PersonalView a WITH(NOEXPAND)
		INNER JOIN
			(
				SELECT ClientID, INDX, ROW_NUMBER() OVER(PARTITION BY INDX ORDER BY ClientFullName) AS CL_RN
				FROM
					(
						SELECT DISTINCT ClientID, ClientFullName, INDX
						FROM Seminar.PersonalView WITH(NOEXPAND)
						WHERE ID_SUBJECT = @SUBJECT
							AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
							AND (FIO LIKE @PERSONAL OR @PERSONAL IS NULL)
					) AS o_O
			) AS b ON a.ClientID = b.ClientID AND a.INDX = b.INDX
		INNER JOIN
			(
				SELECT ClientID, INDX, FIO, ROW_NUMBER() OVER(PARTITION BY INDX ORDER BY ClientFullName, FIO) AS PER_RN
				FROM Seminar.PersonalView WITH(NOEXPAND)
				WHERE ID_SUBJECT = @SUBJECT
					AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
					AND (FIO LIKE @PERSONAL OR @PERSONAL IS NULL)
			) AS c ON a.ClientID = c.ClientID AND a.INDX = c.INDX AND a.FIO = c.FIO
	WHERE a.INDX = 2
		AND ID_SUBJECT = @SUBJECT
		AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
		AND (a.FIO LIKE @PERSONAL OR @PERSONAL IS NULL)
		
	ORDER BY INDX, CL_RN, PER_RN

	/*
	SELECT 
		ID, ClientID, ClientFullName, FIO, SURNAME, NAME, PATRON, POSITION, PHONE, NOTE, COLOR, INDX, UPD_DATE, UPD_USER,
		ServiceName, ServiceStatusIndex
	FROM 
		Seminar.PersonalView WITH(NOEXPAND)
	WHERE ID_SCHEDULE = @SCHEDULE
		AND (ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
		AND (FIO LIKE @PERSONAL OR @PERSONAL IS NULL)
	ORDER BY ID
	*/
END
