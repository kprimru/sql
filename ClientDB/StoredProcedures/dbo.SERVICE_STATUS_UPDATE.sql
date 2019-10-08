USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_STATUS_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@REG	SMALLINT,
	@Code	VarChar(100),
	@INDEX	INT,
	@DEF	INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ServiceStatusTable
	SET ServiceStatusName = @NAME,
		ServiceStatusReg = @REG,
		ServiceCode	= @Code,
		ServiceStatusIndex = @INDEX,
		ServiceDefault = @DEF,
		ServiceStatusLast = GETDATE()
	WHERE ServiceStatusID = @ID
END