USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[DUTY_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DutyName, DutyLogin, DutyActive
	FROM dbo.DutyTable
	WHERE DutyID = @ID
END