USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REFERENCES_RELOAD]
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.SystemDistrType(ID_SYSTEM, ID_TYPE, ENABLE)
	SELECT SystemID, DistrTypeID, 0
	FROM dbo.SystemTable, dbo.DistrTypeTable
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.SystemDistrType
			WHERE ID_SYSTEM = SystemID
				AND ID_TYPE = DistrTypeID
		)

	INSERT INTO dbo.SystemPrice(ID_SYSTEM, ID_PRICE, ENABLED)
	SELECT SystemID, ID, 0
	FROM dbo.SystemTable, dbo.PriceType P
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.SystemPrice SP
			WHERE ID_SYSTEM = SystemID
				AND SP.ID_PRICE = P.ID
		)
END
GO
