USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SystemShortName, SystemName, SystemBaseName, SystemNumber, 
		HostID, SystemRic, SystemOrder, SystemVMI, SystemFullName,
		SystemActive, SystemDemo, SystemComplect, SystemReg, SystemSalaryWeight,
		('<LIST>' + 
			(
				SELECT CONVERT(VARCHAR(50), InfoBankID)AS ITEM
				FROM dbo.SystemBanksView b WITH(NOEXPAND)
				WHERE a.SystemID = b.SystemID AND Required = 1
				ORDER BY InfoBankID FOR XML PATH('')
			) 
		+ '</LIST>') AS IB_REQ_ID,
		('<LIST>' + 
			(
				SELECT CONVERT(VARCHAR(50), InfoBankID)AS ITEM
				FROM dbo.SystemBanksView b WITH(NOEXPAND)
				WHERE a.SystemID = b.SystemID AND Required = 0
				ORDER BY InfoBankID FOR XML PATH('')
			) 
		+ '</LIST>') AS IB_ID
	FROM dbo.SystemTable a
	WHERE SystemID = @ID	
END