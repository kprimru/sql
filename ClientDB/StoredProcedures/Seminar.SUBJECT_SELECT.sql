USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[SUBJECT_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME
	FROM Seminar.Subject
	ORDER BY LAST DESC
END
