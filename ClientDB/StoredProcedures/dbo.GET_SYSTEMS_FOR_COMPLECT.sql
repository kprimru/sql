USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[GET_SYSTEMS_FOR_COMPLECT] 
@typeid INT = 1
AS
BEGIN
	SET NOCOUNT ON

    if @typeid=1 --DEMO
	BEGIN 
		SELECT SystemID, SystemShortName, SystemName, SystemBaseName, SystemOrder
		FROM [dbo].SystemTable 
		WHERE (SystemActive=1)AND(SystemDemo=1)AND(NOT (SystemBaseName in ('BUH', 'BUDU','BUHU', 'RLAW249', 'RLAW011', 'BUHUL', 'RGU', 'RGN')))
		ORDER BY SystemOrder DESC
    END ELSE
    if @typeid=2 --COMPLECT
	BEGIN 
		SELECT SystemID, SystemShortName, SystemName, SystemBaseName, SystemOrder
		FROM [dbo].SystemTable 
		WHERE (SystemActive=1)AND(SystemComplect=1)AND(NOT (SystemBaseName in ('BUH', 'BUHU', 'RLAW249', 'RLAW011', 'RGU' )))
		ORDER BY SystemOrder DESC
    END
	ELSE
	BEGIN --???
		SELECT SystemID, SystemShortName, SystemName, SystemBaseName, SystemOrder
		FROM [dbo].SystemTable 
		WHERE (SystemActive=1)
		ORDER BY SystemOrder DESC

    END	
END