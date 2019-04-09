USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORI_CONTRACT_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT OriContractDate, OriContractSystem, OriContractNote
	FROM dbo.OriContractTable
	WHERE OriContractID = @ID
END