USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_SYSTEMS_FOR_COMPLECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_SYSTEMS_FOR_COMPLECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[GET_SYSTEMS_FOR_COMPLECT]
@typeid INT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_SYSTEMS_FOR_COMPLECT] TO public;
GO
