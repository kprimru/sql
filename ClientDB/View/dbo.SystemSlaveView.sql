USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SystemSlaveView]
AS
	SELECT 
		a.ID_MASTER, b.SystemBaseName AS MASTER_REG, b.SystemShortName AS MASTER_SHORT, 
		a.ID_SLAVE, c.SystemBaseName AS SLAVE_REG, c.SystemShortName AS SLAVE_SHORT
	FROM 
		dbo.SystemComplex a
		INNER JOIN dbo.SystemTable b ON a.ID_MASTER = b.SystemID
		INNER JOIN dbo.SystemTable c ON a.ID_SLAVE = c.SystemID