USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CONTRACT_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	IF (
			SELECT a.IND
			FROM 
				Contract.Status a
				INNER JOIN Contract.Contract b ON a.ID = b.ID_STATUS
			WHERE b.ID = @ID
		) <> 4
	BEGIN
		RAISERROR('������ �������� �� ��������� ��� �������', 16, 1)
		RETURN
	END
	
	DELETE FROM Contract.ContractSpecification WHERE ID_CONTRACT = @ID
	DELETE FROM Contract.Additional WHERE ID_CONTRACT = @ID
	DELETE FROM Contract.Contract WHERE ID = @ID
END
