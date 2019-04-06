USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Din].[NET_TYPE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT NT_NAME, NT_NOTE, NT_NET, NT_TECH, NT_SHORT, NT_ID_MASTER, NT_VMI_SHORT, NT_ODON, NT_ODOFF, NT_TECH_USR
	FROM Din.NetType
	WHERE NT_ID = @ID
END