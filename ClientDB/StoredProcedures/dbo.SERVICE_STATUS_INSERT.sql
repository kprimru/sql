USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_STATUS_INSERT]	
	@NAME	VARCHAR(50),
	@REG	SMALLINT,
	@Code	VarCHar(100),
	@INDEX	INT,
	@DEF	INT,
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ServiceStatusTable(ServiceStatusName, ServiceStatusReg, ServiceStatusIndex, ServiceDefault, ServiceCode)
	VALUES(@NAME, @REG, @INDEX, @DEF, @Code);
		
	SELECT @ID = SCOPE_IDENTITY()
END