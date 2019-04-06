USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DUTY_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@LOGIN	VARCHAR(100),
	@ACTIVE	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.DutyTable
	SET DutyName = @NAME,
		DutyLogin = @LOGIN,
		DutyActive	=	@ACTIVE,
		DutyLast = GETDATE()
	WHERE DutyID = @ID
END