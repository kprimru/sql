USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORI_PERSON_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;


	SELECT OriPersonName, OriPersonPhone, OriPersonPlace
	FROM dbo.OriPersonTable
	WHERE OriPersonID = @ID	
END