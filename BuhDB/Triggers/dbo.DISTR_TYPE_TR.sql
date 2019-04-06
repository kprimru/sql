USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER dbo.DISTR_TYPE_TR
   ON  dbo.DistrTypeTable
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

    INSERT INTO dbo.SystemDistrType(ID_SYSTEM, ID_TYPE, ENABLE)
		SELECT SystemID, DistrTypeID, SystemPrint
		FROM dbo.SystemTable CROSS JOIN dbo.DistrTypeTable
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemDistrType
				WHERE ID_SYSTEM = SystemID
					AND ID_TYPE = DistrTypeID
			)
END
