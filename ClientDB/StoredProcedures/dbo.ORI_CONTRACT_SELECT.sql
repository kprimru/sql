USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORI_CONTRACT_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT OriContractID, OriContractDate, OriContractSystem, OriContractNote
	FROM dbo.OriContractTable
	WHERE ClientID = @CLIENT
	ORDER BY OriContractDate DESC
END