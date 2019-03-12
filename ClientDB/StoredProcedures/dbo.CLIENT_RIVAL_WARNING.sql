USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_RIVAL_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BEGIN	SMALLDATETIME
	DECLARE @END	SMALLDATETIME

	SET @BEGIN = dbo.DateOf(GETDATE())
	SET @END = DATEADD(DAY, 1, dbo.DateOf(GETDATE()))	

	SELECT DISTINCT ClientID, ClientFullName, CR_DATE, CR_CONTROL_DATE
	FROM dbo.ClientRival
		INNER JOIN dbo.ClientTable ON CL_ID = ClientID
	WHERE CR_CONTROL = 1 AND CR_ACTIVE = 1
		AND CR_CONTROL_DATE BETWEEN @BEGIN AND @END
	/*
	UNION

	SELECT DISTINCT ClientID, ClientFullName, CR_DATE, CR_CONTROL_DATE
	FROM dbo.ClientRival
		INNER JOIN dbo.ClientTable ON CL_ID = ClientID
	WHERE CR_COMPLETE = 0 AND CR_ACTIVE = 1
	*/
	ORDER BY CR_DATE DESC, ClientFullName
END