USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_INFOBANKS_FOR_COMPLECT_NEW] 
	@SYSID INT,
    @SYSTYPE INT
AS
BEGIN
	SET NOCOUNT ON
  
    select I.InfoBankID, I.InfoBankName, I.InfoBankShortName,I.InfobankPath  FROM dbo.SystemsBanks SB

    INNER JOIN dbo.InfoBankTable I ON SB.InfoBank_Id = I.InfoBankID
    WHERE (SB.Required in (0,1)) AND SB.System_ID = @SYSID AND SB.DistrType_Id = @SYSTYPE AND 
     I.InfoBankActive=1  AND I.InfobankPath <> ''

END
