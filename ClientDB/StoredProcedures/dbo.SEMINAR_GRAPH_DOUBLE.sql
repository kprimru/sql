USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SEMINAR_GRAPH_DOUBLE]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SELECT a.ClientID, ClientFullName, StudentFam, StudentName, StudentOtch, [Сколько раз посещал]
	FROM 
		(
			SELECT ClientID, StudentFam, StudentName, StudentOtch, COUNT(*) AS [Сколько раз посещал]
			FROM dbo.ClientSeminarView a WITH(NOEXPAND)
			WHERE StudyDate BETWEEN @BEGIN AND @END
			GROUP BY ClientID, StudentFam, StudentName, StudentOtch
			HAVING COUNT(*) > 1
		) a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID	
	ORDER BY StudentFam, StudentName, StudentOtch
END